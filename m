Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9BB82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 23:04:36 -0400 (EDT)
Received: by iody8 with SMTP id y8so87248560iod.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:04:36 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id a126si31794012ioe.74.2015.10.27.20.04.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Oct 2015 20:04:35 -0700 (PDT)
Date: Tue, 27 Oct 2015 22:04:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <20151028024350.GA10448@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
References: <20151028024114.370693277@linux.com> <20151028024131.719968999@linux.com> <20151028024350.GA10448@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Wed, 28 Oct 2015, Tejun Heo wrote:

> The only thing necessary here is WQ_MEM_RECLAIM.  I don't see how
> WQ_SYSFS and WQ_FREEZABLE make sense here.


Subject: vmstat: Remove WQ_FREEZABLE and WQ_SYSFS

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1546,8 +1546,6 @@ static int __init setup_vmstat(void)
 	start_shepherd_timer();
 	cpu_notifier_register_done();
 	vmstat_wq = alloc_workqueue("vmstat",
-		WQ_FREEZABLE|
-		WQ_SYSFS|
 		WQ_MEM_RECLAIM, 0);
 #endif
 #ifdef CONFIG_PROC_FS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
