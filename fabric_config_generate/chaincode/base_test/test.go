package main

import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SimpleAsset struct {
	contractapi.Contract
	Num string `json:"num"`
}

func (s *SimpleAsset) Set(ctx contractapi.TransactionContextInterface, num string) error {
	s.Num = num
	return ctx.GetStub().PutState("num", []byte(num))
}

func (s *SimpleAsset) Get(ctx contractapi.TransactionContextInterface) (string, error) {
	if s.Num == "" {
		value, err := ctx.GetStub().GetState("num")
		if err != nil {
			return "", fmt.Errorf("failed to read num from world state: %w", err)
		}
		if value == nil {
			return "", fmt.Errorf("num does not exist in the world state")
		}
		s.Num = string(value)
	}
	return s.Num, nil
}

func (s *SimpleAsset) Add(ctx contractapi.TransactionContextInterface, num string) (string, error) {
	n, err := strconv.Atoi(num)
	if err != nil {
		return "", fmt.Errorf("failed to convert num to integer: %w", err)
	}

	sum := 1
	for i := 1; i <= n; i++ {
		sum += i
	}
	return strconv.Itoa(sum), nil
}

func (s *SimpleAsset) Mul(ctx contractapi.TransactionContextInterface, num string) (string, error) {
	n, err := strconv.Atoi(num)
	if err != nil {
		return "", fmt.Errorf("failed to convert num to integer: %w", err)
	}

	sum, val := 1, 0xffff
	for i := 1; i <= n; i++ {
		sum += i * val
	}
	return strconv.Itoa(sum), nil
}

func (s *SimpleAsset) Div(ctx contractapi.TransactionContextInterface, num string) (string, error) {
	n, err := strconv.Atoi(num)
	if err != nil {
		return "", fmt.Errorf("failed to convert num to integer: %w", err)
	}

	sum, val := 1, 0xffff
	for i := 1; i <= n; i++ {
		sum += val / i
	}
	return strconv.Itoa(sum), nil
}

func (s *SimpleAsset) Fib(ctx contractapi.TransactionContextInterface, num string) (string, error) {
	n, err := strconv.Atoi(num)
	if err != nil {
		return "", fmt.Errorf("failed to convert num to integer: %w", err)
	}

	sum := s.f(n)
	return strconv.Itoa(sum), nil
}

func (s *SimpleAsset) f(n int) int {
	if n == 1 {
		return 1
	}
	if n == 2 {
		return 1
	}
	return s.f(n-1) + s.f(n-2)
}

func (s *SimpleAsset) Init(ctx contractapi.TransactionContextInterface) error {
	ctx.GetStub().PutState("lefthand", []byte("10"))
	ctx.GetStub().PutState("righthand", []byte("10"))
	return ctx.GetStub().PutState("body", []byte("lefthand"))
}
func (s *SimpleAsset) Transfer(ctx contractapi.TransactionContextInterface, sender string, receiver string) error {
	value1, err := ctx.GetStub().GetState(sender)
	if err != nil {
		return fmt.Errorf("failed to read sender from world state: %w", err)
	}
	value2, err := ctx.GetStub().GetState(receiver)
	if err != nil {
		return fmt.Errorf("failed to read sender from world state: %w", err)
	}
	sender_account, err := strconv.Atoi(string(value1))
	receiver_account, err := strconv.Atoi(string(value2))
	sender_account += 1
	receiver_account -= 1
	ctx.GetStub().PutState(sender, []byte(strconv.Itoa(sender_account)))
	ctx.GetStub().PutState(receiver, []byte(strconv.Itoa(receiver_account)))

	return ctx.GetStub().PutState("body", []byte(receiver))
}

func main() {
	cc, err := contractapi.NewChaincode(new(SimpleAsset))
	if err != nil {
		fmt.Printf("Error creating SimpleAsset chaincode: %s", err.Error())
		return
	}

	if err := cc.Start(); err != nil {
		fmt.Printf("Error starting SimpleAsset chaincode: %s", err.Error())
	}
}
