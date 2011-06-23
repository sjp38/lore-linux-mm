Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 559FD900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:52:28 -0400 (EDT)
Message-ID: <4E02E283.3080702@redhat.com>
Date: Thu, 23 Jun 2011 14:51:47 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP configurable
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com> <4E015C36.2050005@redhat.com> <alpine.DEB.2.00.1106212024210.8712@chino.kir.corp.google.com> <4E018060.3050607@redhat.com> <alpine.DEB.2.00.1106212325400.14693@chino.kir.corp.google.com> <4E01CCED.5050609@redhat.com> <20110622144057.GW20843@redhat.com>
In-Reply-To: <20110622144057.GW20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 22:40, Andrea Arcangeli a??e??:
> On Wed, Jun 22, 2011 at 07:07:25PM +0800, Cong Wang wrote:
>> Actually, if we move this out of kernel, to user-space, everything
>> you worried will be solved by just changing the user-space code.
>> Just add the following pseudo code into your init script,
>>
>> if [ $total_memory -lt 512 ]
>> then
>> 	echo never>  /sys/kernel/mm/transparent_hugepage/enabled
>> fi
>
> By the time this script runs some app may have allocated hugepages
> already potentially wasting mbytes of ram and undoing the
> min_free_kbytes isn't possible from userland using the kernel
> algorithm (it is possible actually but it's not nearly as simple as
> the above).

I remember there is a way to tell init-scripts to run it as early as
possible. :)

>
> There's no reason to complicate things and involve userland here when
> a simple kernel check can get the default right without userland
> dependency. Plus if this user really wants THP on 512m of ram he can
> still enable it and run hugeadm to enable antifrag too, without the
> need of =force. And forcing when PSE is enabled sounds impossible to be
> useful (maybe with the except of nopentium being passed to the kernel ;).
>
> There is no bug here, just send that printk cleanup and if you really
> want to save 8k the patch to change the number of hash heads structs
> at boot, like for dcache/icache. No other change required.


I never said this is a bug, I just don't think it is flexible. ;)

>
> After you do the above, you can go ahead picking one kernel crashing
> bug and fix it, that is more useful than making this 512m thing a
> .config variable or anything like that, .config is a nightmare already
> so it's probably better not to add anything there.

Well, I can't agree with this point.

Since we can't persuade each other, I give up.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
