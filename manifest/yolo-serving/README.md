# YOLO Serving manifests

## ジョブ再実行の挙動
- `job-download-model-yolo.yaml` は通常の `Job` として定義されており、`restartPolicy: Never` で一度だけ実行されます。
- Argo CD の `ApplicationSet` 側は `automated` + `selfHeal` で構成しているため、`Job` を削除すると Argo CD の自己修復や再 Sync で再作成されます。
- 完了状態の `Job` がそのまま残っていると再実行されません。もう一度動かしたい場合は、以下の手順で `Job` を消してから Sync してください。
  1. `kubectl delete job job-download-model-yolo -n yolo-serving`
  2. Argo CD で `yolo-serving` アプリを Sync（または数秒待てば自己修復で自動作成されます）
- 繰り返し実行したい場合は `CronJob` 化などを検討してください。
