Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1126B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:13:57 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id js7so27142049obc.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 04:13:57 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l190si23270240oib.51.2016.04.19.04.13.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 04:13:56 -0700 (PDT)
Message-ID: <571612DE.8020908@huawei.com>
Date: Tue, 19 Apr 2016 19:13:34 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: mce: a question about memory_failure_early_kill in memory_failure()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>

/proc/sys/vm/memory_failure_early_kill

1: means kill all processes that have the corrupted and not reloadable page mapped.
0: means only unmap the corrupted page from all processes and only kill a process
who tries to access it.

If set memory_failure_early_kill to 0, and memory_failure() has been called.
memory_failure()
	hwpoison_user_mappings()
		collect_procs()  // the task(with no PF_MCE_PROCESS flag) is not in the tokill list
			try_to_unmap()

If the task access the memory, there will be a page fault,
so the task can not access the original page again, right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
