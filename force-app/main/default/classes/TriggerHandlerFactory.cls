public class TriggerHandlerFactory {

    public static void execute(Type handlerType) {
        Object handler = handlerType.newInstance();
        
        if (!(handler instanceOf TriggerHandler)) {
            throw new TriggerHandlerException('The class must implement the TriggerHandler interface');
        }
        
        executeTriggerHandler((TriggerHandler)handler);
    }
    
    private static void executeTriggerHandler(TriggerHandler handler) {
        if (Trigger.isBefore) {
            executeBeforeMethods(handler);
        }
        else if (Trigger.isAfter) {
            executeAfterMethods(handler);
        }
    }
    
    private static void executeBeforeMethods(TriggerHandler handler) {
        if (Trigger.isInsert) {
            handler.beforeInsert();
        }
        else if (Trigger.isUpdate) {
            handler.beforeUpdate();
        }
        else if (Trigger.isDelete) {
            handler.beforeDelete();
        }
    }
    
    private static void executeAfterMethods(TriggerHandler handler) {
        if (Trigger.isInsert) {
            handler.afterInsert();
        }
        else if (Trigger.isUpdate) {
            handler.afterUpdate();
        }
        else if (Trigger.isDelete){
            handler.afterDelete();
        }
    }
    
    public class TriggerHandlerException extends Exception {
        
    }
}