Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 941B46B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 02:55:05 -0400 (EDT)
Received: by wwj40 with SMTP id 40so3220834wwj.26
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 23:55:02 -0700 (PDT)
Subject: Re: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4E25221F.6060605@redhat.com>
References: <1310987909-3129-1-git-send-email-amwang@redhat.com>
	 <20110718135243.GA5349@suse.de>  <4E25221F.6060605@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jul 2011 08:54:58 +0200
Message-ID: <1311058498.16961.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

Le mardi 19 juillet 2011 A  14:20 +0800, Cong Wang a A(C)crit :

> Hmm, since we don't have to enable SYSFS for NUMA, how about
> make a new Kconfig for drivers/base/node.c? I.e., CONFIG_NUMA_SYSFS,
> like patch below.
> 

I dont quite understand this patch, nor the idea behind it.

You can have a NUMA kernel (for appropriate percpu locality or whatever
kernel data), and yet user land processes unable to use numactl if SYSFS
is not enabled. I dont see a problem.

Please just fix the link problem ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
