Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id ADB2F6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:26:34 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1647867pbb.36
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:26:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id zj1si7348279pbb.323.2014.04.18.10.26.32
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 10:26:33 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 01/16] mm: Disable zone_reclaim_mode by default
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
	<1397832643-14275-2-git-send-email-mgorman@suse.de>
Date: Fri, 18 Apr 2014 10:26:28 -0700
In-Reply-To: <1397832643-14275-2-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Fri, 18 Apr 2014 15:50:28 +0100")
Message-ID: <87tx9q35x7.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:

> zone_reclaim_mode causes processes to prefer reclaiming memory from local
> node instead of spilling over to other nodes. This made sense initially when
> NUMA machines were almost exclusively HPC and the workload was partitioned
> into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> the memory. On current machines and workloads it is often the case that
> zone_reclaim_mode destroys performance but not all users know how to detect
> this. 

Non local memory also often destroys performance.

> Favour the common case and disable it by default. Users that are
> sophisticated enough to know they need zone_reclaim_mode will detect it.

While I'm not totally against this change, it will destroy many
carefully tuned configurations as the default NUMA behavior may be completely
different now. So it seems like a big hammer, and it's not even clear
what problem you're exactly solving here.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
