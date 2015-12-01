Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C0DC46B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:41:38 -0500 (EST)
Received: by pacej9 with SMTP id ej9so20292101pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:41:38 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id b65si282255pfj.253.2015.12.01.15.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:41:38 -0800 (PST)
Received: by padhx2 with SMTP id hx2so20328926pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:41:38 -0800 (PST)
Date: Tue, 1 Dec 2015 15:41:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] bugfix oom kill init lead panic
In-Reply-To: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
Message-ID: <alpine.DEB.2.10.1512011540550.23632@chino.kir.corp.google.com>
References: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, akpm@linux-foundation.org, stable@vger.kernel.org

On Mon, 30 Nov 2015, chenjie6@huawei.com wrote:

> From: chenjie <chenjie6@huawei.com>
> 
> when oom happened we can see:
> Out of memory: Kill process 9134 (init) score 3 or sacrifice child                  
> Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
> Kill process 1 (init) sharing same memory
> ...
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
> 
> That's because:
> 	the busybox init will vfork a process,oom_kill_process found
> the init not the children,their mm is the same when vfork.
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Chen Jie <chenjie6@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
