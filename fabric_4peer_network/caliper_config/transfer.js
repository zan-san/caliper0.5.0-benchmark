'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }
    
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }
    
    async submitTransaction() {
        const randomId = Math.floor(Math.random()*this.roundArguments.assets);
        let num = Math.floor(Math.random() * 2);
        let payload1 = "lefthand righthand";
        let payload2 = "lefthand righthand";
        if (num ==1){
            payload1 = "lefthand";
            payload2 = "righthand";
        }else{
            payload1 = "righthand";
            payload2 = "lefthand";
        }
        const myArgs = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'set',
            contractArguments: [payload1,payload2],
            readOnly: true
        };

        await this.sutAdapter.sendRequests(myArgs);
    }
    
    async cleanupWorkloadModule() {
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;