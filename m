Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B4CD36B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 09:30:07 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7PD5rK9022345
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 09:05:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7PDTsFr366836
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 09:30:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7PDTqll029402
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 09:29:53 -0400
Message-ID: <4E564E4D.4030302@linux.vnet.ibm.com>
Date: Thu, 25 Aug 2011 08:29:49 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code
References: <20110823145815.GA23190@ca-server1.us.oracle.com> <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, jackdachef@gmail.com, cyclonusj@gmail.com

On 08/25/2011 01:05 AM, KAMEZAWA Hiroyuki wrote:
> On Tue, 23 Aug 2011 07:58:15 -0700
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
> 
>> From: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Subject: [PATCH V7 2/4] mm: frontswap: core code
>>
>> This second patch of four in this frontswap series provides the core code
>> for frontswap that interfaces between the hooks in the swap subsystem and
>> a frontswap backend via frontswap_ops.
>>
>> Two new files are added: mm/frontswap.c and include/linux/frontswap.h
>>
>> Credits: Frontswap_ops design derived from Jeremy Fitzhardinge
>> design for tmem; sysfs code modelled after mm/ksm.c
>>
>> [v7: rebase to 3.0-rc3]
>> [v7: JBeulich@novell.com: new static inlines resolve to no-ops if not config'd]
>> [v7: JBeulich@novell.com: avoid redundant shifts/divides for *_bit lib calls]
>> [v6: rebase to 3.1-rc1]
>> [v6: lliubbo@gmail.com: fix null pointer deref if vzalloc fails]
>> [v6: konrad.wilk@oracl.com: various checks and code clarifications/comments]
>> [v5: no change from v4]
>> [v4: rebase to 2.6.39]
>> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
>> Acked-by: Jan Beulich <JBeulich@novell.com>
>> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Matthew Wilcox <matthew@wil.cx>
>> Cc: Chris Mason <chris.mason@oracle.com>
>> Cc: Rik Riel <riel@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>
<cut>
> 
> 
> I'm sorry if I miss codes but.... is an implementation of frontswap.ops included
> in this patch set ? Or how to test the work ?

The zcache driver (in drivers/staging/zcache) is the one that registers frontswap ops.

You can test frontswap by enabling CONFIG_FRONTSWAP and CONFIG_ZCACHE, and putting 
"zcache" in the kernel boot parameters.

> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
