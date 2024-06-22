public interface TriggerHandler {
    void beforeInsert();
    void beforeUpdate();
    void beforeDelete();
    void afterInsert();
    void afterUpdate();
    void afterDelete();
}