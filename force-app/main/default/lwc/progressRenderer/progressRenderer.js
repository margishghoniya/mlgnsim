import { LightningElement, api } from 'lwc';

export default class ProgressRenderer extends LightningElement {

    //==========================================
    // Widget received from Parent
    //==========================================
    @api widget;

    //==========================================
    // Check Data
    //==========================================
    get hasData(){

        return this.widget &&
               this.widget.items &&
               this.widget.items.length>0;

    }

    //==========================================
    // No Data
    //==========================================
    get showNoData(){

        return !this.hasData;

    }

    //==========================================
    // Prepare Progress Items
    //==========================================
    get progressItems(){

        if(!this.hasData){

            return [];

        }

        return this.widget.items.map((item,index)=>{

            const value = Number(item.value);

            return{

                id:'PROGRESS_'+index,

                label:item.label,

                value:value,

                status:this.getStatus(value),

                barClass:this.getBarClass(value),

                textClass:this.getTextClass(value),

                style:'width:'+value+'%;'

            };

        });

    }

    //==========================================
    // Status Text
    //==========================================
    getStatus(value){

        if(value>=90){

            return 'Excellent';

        }

        if(value>=75){

            return 'Good';

        }

        if(value>=60){

            return 'Average';

        }

        if(value>=40){

            return 'Needs Review';

        }

        return 'High Risk';

    }

    //==========================================
    // Progress Bar CSS
    //==========================================
    getBarClass(value){

        if(value>=90){

            return 'progressHigh';

        }

        if(value>=75){

            return 'progressGood';

        }

        if(value>=60){

            return 'progressMedium';

        }

        if(value>=40){

            return 'progressWarning';

        }

        return 'progressLow';

    }

    //==========================================
    // Text Color
    //==========================================
    getTextClass(value){

        if(value>=90){

            return 'textHigh';

        }

        if(value>=75){

            return 'textGood';

        }

        if(value>=60){

            return 'textMedium';

        }

        if(value>=40){

            return 'textWarning';

        }

        return 'textLow';

    }

    //==========================================
    // Refresh Widget
    //==========================================
    @api
    refresh(widget){

        this.widget = widget;

    }

    //==========================================
    // Average Score
    //==========================================
    get averageScore(){

        if(!this.hasData){

            return 0;

        }

        let total = 0;

        this.widget.items.forEach(item=>{

            total += Number(item.value);

        });

        return Math.round(total/this.widget.items.length);

    }

    //==========================================
    // Highest Score
    //==========================================
    get highestScore(){

        if(!this.hasData){

            return 0;

        }

        let values=this.widget.items.map(item=>Number(item.value));

        return Math.max(...values);

    }

    //==========================================
    // Lowest Score
    //==========================================
    get lowestScore(){

        if(!this.hasData){

            return 0;

        }

        let values=this.widget.items.map(item=>Number(item.value));

        return Math.min(...values);

    }

    //==========================================
    // Total Items
    //==========================================
    get totalItems(){

        if(!this.hasData){

            return 0;

        }

        return this.widget.items.length;

    }

}