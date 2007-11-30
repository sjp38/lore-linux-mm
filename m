Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAU4JRM3010496
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 23:19:27 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAU4JOgN127684
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 21:19:26 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAU4JOSY020039
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 21:19:24 -0700
Date: Thu, 29 Nov 2007 20:19:22 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
Message-ID: <20071130041922.GQ13444@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com> <1196378080.18851.116.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1196378080.18851.116.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.11.2007 [15:14:40 -0800], Dave Hansen wrote:
> On Thu, 2007-11-29 at 13:48 -0800, Nishanth Aravamudan wrote:
> > __GFP_NOFAIL means repeat forever
> > 
> > order <= PAGE_ALLOC_COSTLY_ORDER means __GFP_NOFAIL 
> 
> If this is true, why do we still pass in __GFP_REPEAT to the
> pgd_alloc() functions (at least in x86's pgalloc_64.h and
> pgtable_32.c).  We don''t ever have pagetables exceeding
> PAGE_ALLOC_COSTLY_ORDER, do we?

That's a very good question. And is related to one of mine that you
snipped:

"In looking at the callers using __GFP_REPEAT, not all handle failure --
should they be using __NOFAIL?"

I *think* that all the current __GFP_REPEAT users are order <=
PAGE_ALLOC_CSOTLY_ORDER. Perhaps they all mean to use __GPF_NOFAIL? Some
don't handle failure immediately, but maybe their callers do, I haven't
had time to investigate fully.

And the whole gist, per the comments in mm/page_alloc.c, is that this is
all dependent upon this implementation of the VM. I think that means you
can't rely on those semantics being valid forever. So it's best for
callers to be as explicit as possible ... but in this case, I'm not sure
that the desired semantics actually exist.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
