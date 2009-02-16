Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF0E6B00C4
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:47:24 -0500 (EST)
Message-ID: <4999C1CE.8080002@cs.helsinki.fi>
Date: Mon, 16 Feb 2009 21:43:10 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] SLQB slab allocator (try 2)
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi> <20090216194157.GB31264@csn.ul.ie>
In-Reply-To: <20090216194157.GB31264@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Mon, Feb 16, 2009 at 09:17:58PM +0200, Pekka Enberg wrote:
>> Hi Mel,
>>
>> Mel Gorman wrote:
>>> I haven't done much digging in here yet. Between the large page bug and
>>> other patches in my inbox, I haven't had the chance yet but that doesn't
>>> stop anyone else taking a look.
>> So how big does an improvement/regression have to be not to be  
>> considered within noise? I mean, I randomly picked one of the results  
>> ("x86-64 speccpu integer tests") and ran it through my "summarize"  
>> script and got the following results:
>>
>> 		min      max      mean     std_dev
>>   slub		0.96     1.09     1.01     0.04
>>   slub-min	0.95     1.10     1.00     0.04
>>   slub-rvrt	0.90     1.08     0.99     0.05
>>   slqb		0.96     1.07     1.00     0.04
>>
> 
> Well, it doesn't make a whole pile of sense to get the average of these ratios
> or the deviation between them. Each of the tests behave very differently.

Uhm, yes. I need to learn to read one of these days.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
