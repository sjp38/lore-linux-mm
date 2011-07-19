Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D42CB6B007E
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:06:06 -0400 (EDT)
Message-ID: <4E252CA1.803@redhat.com>
Date: Tue, 19 Jul 2011 15:05:05 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
References: <1310987909-3129-1-git-send-email-amwang@redhat.com>	 <20110718135243.GA5349@suse.de>  <4E25221F.6060605@redhat.com> <1311058498.16961.15.camel@edumazet-laptop>
In-Reply-To: <1311058498.16961.15.camel@edumazet-laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

ao? 2011a1'07ae??19ae?JPY 14:54, Eric Dumazet a??e??:
> Le mardi 19 juillet 2011 A  14:20 +0800, Cong Wang a A(C)crit :
>
>> Hmm, since we don't have to enable SYSFS for NUMA, how about
>> make a new Kconfig for drivers/base/node.c? I.e., CONFIG_NUMA_SYSFS,
>> like patch below.
>>
>
> I dont quite understand this patch, nor the idea behind it.
>
> You can have a NUMA kernel (for appropriate percpu locality or whatever
> kernel data), and yet user land processes unable to use numactl if SYSFS
> is not enabled. I dont see a problem.
>

Both Pekka and Mel pointed out that it makes sense to have NUMA kernel
without SYSFS, this means sysfs interface is not a must for NUMA kernel.
Thus, I think it makes sense to separate the numa sysfs code out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
