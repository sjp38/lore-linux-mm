Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id B3ACD6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 03:50:35 -0400 (EDT)
Received: by oigk185 with SMTP id k185so54209622oig.2
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 00:50:35 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m7si9160305obv.25.2015.08.31.00.50.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 00:50:35 -0700 (PDT)
Message-ID: <55E40356.3050800@huawei.com>
Date: Mon, 31 Aug 2015 15:33:42 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: is it a problem when cat /proc/pid/status
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: qiuxishi@huawei.com, guohanjun@huawei.com


I want to know whether the NUMA bound memory node with CONFIG_CGROUPS related or associted with NUMA binding.

I wrote an example test,the results are as follows.

> euler-linux:/home/zhongjiang # numactl --membind=1 ./new &
> [1] 6529
> euler-linux:/home/zhongjiang # ps -ef | grep new
> root      6529  4483  0 14:40 pts/1    00:00:00 ./new
> root      6556  4483  0 14:40 pts/1    00:00:00 grep new
> euler-linux:/home/zhongjiang # cat /proc/6529/status
> Name:   new
> State:  S (sleeping)
  ........
> Cpus_allowed:   ffffff
> Cpus_allowed_list:      0-23
> Mems_allowed:   00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,007fffff
> Mems_allowed_list:      0-22
> voluntary_ctxt_switches:        19
> nonvoluntary_ctxt_switches:     0


euler-linux:/home/zhongjiang # numactl --membind=3 ./new &
[1] 9113
euler-linux:/home/zhongjiang # ps -ef | grep mew
root      9140  8948  0 14:55 pts/1    00:00:00 grep mew
euler-linux:/home/zhongjiang # ps -ef | grep new
root      9113  8948  0 14:55 pts/1    00:00:00 ./new
root      9209  8948  0 14:55 pts/1    00:00:00 grep new
euler-linux:/home/zhongjiang # cat /proc/9113/status
Name:   new
State:  S (sleeping)
Tgid:   9113
Ngid:   0
Pid:    9113
PPid:   8948
......
Cpus_allowed:   ffffff
Cpus_allowed_list:      0-23
Mems_allowed:   00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,007fffff
Mems_allowed_list:      0-22
voluntary_ctxt_switches:        26
nonvoluntary_ctxt_switches:     0

Through the comparison of the above, I can find Whatever I use node for binding, the mems_allowed fields has been no change

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
