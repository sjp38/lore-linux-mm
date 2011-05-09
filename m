Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AC0596B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:23:06 -0400 (EDT)
Message-ID: <4DC86947.30607@linux.intel.com>
Date: Mon, 09 May 2011 15:23:03 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>	<1304623972-9159-2-git-send-email-andi@firstfloor.org> <20110509144324.8e79654a.akpm@linux-foundation.org>
In-Reply-To: <20110509144324.8e79654a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie


>> +static inline void anon_vma_unlock_batch(struct anon_vma_lock_state *avs)
>> +{
>> +	if (avs->root_anon_vma)
>> +		spin_unlock(&avs->root_anon_vma->lock);
>> +}
>> +
>>   /*
>>    * anon_vma helper functions.
>>    */
> The code doesn't build - the patchset forgot to add `spinlock_t lock'
> to the anon_vma.

Hmm, maybe I made a mistake in refactoring.

> After fixing that and doing an allnoconfig x86_64 build, the patchset
> takes rmap.o's .text from 6167 bytes to 6551.  This is likely to be a
> regression for uniprocessor machines.  What can we do about this?
>

Regression in what way? I guess I can move some of the functions out of 
line.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
