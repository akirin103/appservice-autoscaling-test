## 負荷テスト

1. AzureポータルからAppService-SSHで接続する。

2. `stress-ng`をインストールする。
    (インストール)
    ```
    $ apt update
    $ apt install stress-ng
    $ stress-ng --version
    > stress-ng, version 0.09.50
    ```

3. AppServicePlan負荷をかける。
    ```
    # バックグラウンドでCPU
    $ stress-ng -c 1 -l 80 -q &
    # プロセスの確認
    $ ps -C stress-ng,stress-ng-cpu -o comm,pid,ppid,wchan,%cpu
    # ジョブの確認
    $ jobs
    # プロセスのリソース消費量を確認
    $ top
    # ジョブの停止
    $ kill <プロセス番号>
    ```

4. オートスケーリングを確認する。

    - Azureポータルの「アクティビティログ」で下記のように表示される。
        - `Autoscale scale up completed`
        - `Autoscale scale down completed`
    - Azureポータルの「概要」で下記の表示になっている。  
        - `App Service プラン: <appserviceplan名> (S1: 2)`  
        - (S1: 2) -> 2の部分がインスタンス数  
    - Azureポータルの「スケール アウト (App Service のプラン)」でインスタンス数が表示されている。  

<br />

5. 備考
    - リソースグループにあるAppServicePlanが増えたりする訳ではなく、一つのappserviceplanの中で複数のインスタンスを管理している。appserviceplan1、appserviceplan2と増える訳ではない。
    - AppServicePlanは基本Debianっぽい。
        ```
        $ cat /etc/issue
        > Debian GNU/Linux 10
        ```

` 
