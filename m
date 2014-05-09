Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 277296B0037
	for <linux-mm@kvack.org>; Fri,  9 May 2014 06:33:11 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so1733991pab.20
        for <linux-mm@kvack.org>; Fri, 09 May 2014 03:33:10 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id xd9si1402488pab.19.2014.05.09.03.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 03:33:10 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so3512290pde.40
        for <linux-mm@kvack.org>; Fri, 09 May 2014 03:33:09 -0700 (PDT)
Date: Fri, 9 May 2014 03:33:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Kernel panic related with OOM-killer
In-Reply-To: <536C3FC7.2030402@huawei.com>
Message-ID: <alpine.DEB.2.02.1405090329360.15089@chino.kir.corp.google.com>
References: <536C3FC7.2030402@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

On Fri, 9 May 2014, Zhang Zhen wrote:

> Hi,
> 
> We have a question about Kernel panic related with OOM-killer on an ARM-A15 board.
> But it reproduced randomly.
> 
> Does anyone has some issues like this or some suggestion?
> Thank you so much.
> 
> The Logs when kernel panic was occurred as follows.
> 
> [59313.549221] Killed process 15479 (server) total-vm:9984kB, anon-rss:68kB, file-rss:0kB
> [59318.531080] Out of memory: Kill process 15485 (server) score 0 or sacrifice child
> [59318.618689] Killed process 15485 (server) total-vm:9984kB, anon-rss:68kB, file-rss:0kB
> [59321.839161] Out of memory: Kill process 1339 (portmap) score 0 or sacrifice child
> [59321.926735] Killed process 1339 (portmap) total-vm:1732kB, anon-rss:64kB, file-rss:0kB
> [59327.626410] Kernel panic - not syncing: Out of memory and no killable processes...

This is the key, there are no eligible processes available to kill on the 
system.  All processes on the system are either kthreads or oom disabled 
(their /proc/<pid>/oom_score_adj is -1000), see section 3.1 of 
Documentation/filesystems/proc.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
