Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF21E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 09:38:50 -0500 (EST)
Date: Wed, 9 Mar 2011 16:36:35 +0200 (EET)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCHv2] procfs: fix /proc/<pid>/maps heap check
In-Reply-To: <20110307150756.d50635f1.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.1103091631280.23039@esdhcp041196.research.nokia.com>
References: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com> <20110307150756.d50635f1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, stable@kernel.org

Hi,

On Mon, 7 Mar 2011, Andrew Morton wrote:
> On Fri,  4 Mar 2011 15:23:14 +0200
> Aaro Koskinen <aaro.koskinen@nokia.com> wrote:
>
>> The current code fails to print the "[heap]" marking if the heap is
>> splitted into multiple mappings.
>>
>> Fix the check so that the marking is displayed in all possible cases:
>> 	1. vma matches exactly the heap
>> 	2. the heap vma is merged e.g. with bss
>> 	3. the heap vma is splitted e.g. due to locked pages
>>
>> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
>> Cc: stable@kernel.org
>
> Why do you believe this problem is serious enough to justify
> backporting the fix into -stable?

My bad analysis. It looks like the bug has been there forever, and
since it only results in some information missing from a procfile,
it does not fulfil the stable "critical issue" criteria.

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
