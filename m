Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF876B00BA
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:22:14 -0500 (EST)
Message-ID: <4999BBE6.2080003@cs.helsinki.fi>
Date: Mon, 16 Feb 2009 21:17:58 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] SLQB slab allocator (try 2)
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie>
In-Reply-To: <20090216184200.GA31264@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

Mel Gorman wrote:
> I haven't done much digging in here yet. Between the large page bug and
> other patches in my inbox, I haven't had the chance yet but that doesn't
> stop anyone else taking a look.

So how big does an improvement/regression have to be not to be 
considered within noise? I mean, I randomly picked one of the results 
("x86-64 speccpu integer tests") and ran it through my "summarize" 
script and got the following results:

		min      max      mean     std_dev
   slub		0.96     1.09     1.01     0.04
   slub-min	0.95     1.10     1.00     0.04
   slub-rvrt	0.90     1.08     0.99     0.05
   slqb		0.96     1.07     1.00     0.04

Apart from slub-rvrt (which seems to be regressing, interesting) all the 
allocators seem to perform equally well. Hmm?

Btw, Yanmin, do you have access to the tests Mel is running (especially 
the ones where slub-rvrt seems to do worse)? Can you see this kind of 
regression? The results make we wonder whether we should avoid reverting 
all of the page allocator pass-through and just add a kmalloc cache for 
8K allocations. Or not address the netperf regression at all. Double-hmm.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
