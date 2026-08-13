import { LightningElement, api } from 'lwc';

export default class TimelineRenderer extends LightningElement {

    //=========================================================
    // Widget received from parent
    //=========================================================
    @api widget;

    //=========================================================
    // Check Data
    //=========================================================
    get hasData(){

        return this.widget &&
               this.widget.items &&
               this.widget.items.length > 0;

    }

    //=========================================================
    // No Data
    //=========================================================
    get showNoData(){

        return !this.hasData;

    }

    //=========================================================
    // Build Timeline
    //=========================================================
    get timelineItems(){

        if(!this.hasData){

            return [];

        }

        return this.widget.items.map((item,index)=>{

            return{

                id:'TIMELINE_'+index,

                title:item.title,

                time:item.time,

                status:item.status,

                description:item.description,

                icon:this.getIcon(item),

                circleClass:this.getCircleClass(item.status),

                statusClass:this.getStatusClass(item.status),

                isLast:index===this.widget.items.length-1,

                metrics:this.prepareMetrics(item,index),

                evidence:this.prepareEvidence(item,index)

            };

        });

    }

    //=========================================================
    // Prepare Metrics
    //=========================================================
    prepareMetrics(item,rowIndex){

        if(!item.metrics){

            return null;

        }

        return item.metrics.map((metric,index)=>{

            return{

                id:'METRIC_'+rowIndex+'_'+index,

                label:metric.label,

                value:metric.value

            };

        });

    }

    //=========================================================
    // Prepare Evidence
    //=========================================================
    prepareEvidence(item,rowIndex){

        if(!item.evidence){

            return null;

        }

        return item.evidence.map((doc,index)=>{

            return{

                id:'DOC_'+rowIndex+'_'+index,

                name:doc.name

            };

        });

    }
        //=========================================================
    // Status CSS Class
    //=========================================================
    getStatusClass(status){

        if(!status){

            return 'statusPending';

        }

        const value = status.toLowerCase();

        switch(value){

            case 'completed':
                return 'statusCompleted';

            case 'running':
                return 'statusRunning';

            case 'warning':
                return 'statusWarning';

            case 'failed':
                return 'statusFailed';

            case 'review':
                return 'statusReview';

            case 'pending':
            default:
                return 'statusPending';

        }

    }

    //=========================================================
    // Circle CSS Class
    //=========================================================
    getCircleClass(status){

        if(!status){

            return 'circlePending';

        }

        const value = status.toLowerCase();

        switch(value){

            case 'completed':
                return 'circleCompleted';

            case 'running':
                return 'circleRunning';

            case 'warning':
                return 'circleWarning';

            case 'failed':
                return 'circleFailed';

            case 'review':
                return 'circleReview';

            case 'pending':
            default:
                return 'circlePending';

        }

    }

    //=========================================================
    // Timeline Icon
    //=========================================================
    getIcon(item){

        // If icon comes from JSON use it
        if(item.icon){

            return item.icon;

        }

        // Otherwise decide based on status
        if(!item.status){

            return 'utility:clock';

        }

        const status = item.status.toLowerCase();

        switch(status){

            case 'completed':
                return 'utility:success';

            case 'running':
                return 'utility:einstein';

            case 'warning':
                return 'utility:warning';

            case 'failed':
                return 'utility:error';

            case 'review':
                return 'utility:preview';

            default:
                return 'utility:clock';

        }

    }

    //=========================================================
    // Refresh Component
    //=========================================================
    @api
    refresh(widget){

        this.widget = widget;

    }

    //=========================================================
    // Total Timeline Steps
    //=========================================================
    get totalSteps(){

        if(!this.hasData){

            return 0;

        }

        return this.widget.items.length;

    }

    //=========================================================
    // Completed Steps
    //=========================================================
    get completedSteps(){

        if(!this.hasData){

            return 0;

        }

        return this.widget.items.filter(item =>

            item.status &&
            item.status.toLowerCase() === 'completed'

        ).length;

    }

    //=========================================================
    // Running Steps
    //=========================================================
    get runningSteps(){

        if(!this.hasData){

            return 0;

        }

        return this.widget.items.filter(item =>

            item.status &&
            item.status.toLowerCase() === 'running'

        ).length;

    }

    //=========================================================
    // Failed Steps
    //=========================================================
    get failedSteps(){

        if(!this.hasData){

            return 0;

        }

        return this.widget.items.filter(item =>

            item.status &&
            item.status.toLowerCase() === 'failed'

        ).length;

    }

    //=========================================================
    // Completion Percentage
    //=========================================================
    get completionPercent(){

        if(!this.hasData){

            return 0;

        }

        return Math.round(

            (this.completedSteps / this.totalSteps) * 100

        );

    }

}