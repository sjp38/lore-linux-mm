Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D47A36B00E7
	for <linux-mm@kvack.org>; Sun, 13 May 2012 22:33:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0DC953EE0BC
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:33:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E938045DE55
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:33:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D468E45DE54
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:33:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C87FFE08003
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:33:27 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 805F41DB8045
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:33:27 +0900 (JST)
Message-ID: <4FB06F09.5060105@jp.fujitsu.com>
Date: Mon, 14 May 2012 11:33:45 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory: add kernelcore_max_addr boot option
References: <4FACA79C.9070103@cn.fujitsu.com> <20120511133939.25b5a738.akpm@linux-foundation.org>
In-Reply-To: <20120511133939.25b5a738.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,

2012/05/12 5:39, Andrew Morton wrote:
> On Fri, 11 May 2012 13:46:04 +0800
> Lai Jiangshan<laijs@cn.fujitsu.com>  wrote:
>
>> Current ZONE_MOVABLE (kernelcore=) setting policy with boot option doesn't meet
>> our requirement. We need something like kernelcore_max_addr= boot option
>> to limit the kernelcore upper address.
>
> Why do you need this?  Please fully describe the requirement/use case.

We want to create removable node for removing a system board
which equip CPU and memory at runtime. To do this, all memory
of a node on system board must be allocated as ZONE_MOVABLE.
But current linux cannot do it.
So we create removable node by limiting the memory address of
the kernelcore by the boot option.

Thanks,
Yasuaki Ishimatsu

>> The memory with higher address will be migratable(movable) and they
>> are easier to be offline(always ready to be offline when the system don't require
>> so much memory).
>>
>> All kernelcore_max_addr=, kernelcore= and movablecore= can be safely specified
>> at the same time(or any 2 of them).
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
