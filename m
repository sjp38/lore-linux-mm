Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B927E6B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 11:58:09 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so1502338pde.28
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 08:58:09 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sn7si20234329pab.283.2013.11.22.08.58.07
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 08:58:08 -0800 (PST)
Message-ID: <528F8CE2.1000001@intel.com>
Date: Fri, 22 Nov 2013 08:57:06 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: NUMA? bisected performance regression 3.11->3.12
References: <528E8FCE.1000707@intel.com> <20131122052219.GL3556@cmpxchg.org> <528EF744.8040607@intel.com> <20131122063845.GM3556@cmpxchg.org>
In-Reply-To: <20131122063845.GM3556@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>

On 11/21/2013 10:38 PM, Johannes Weiner wrote:
> On Thu, Nov 21, 2013 at 10:18:44PM -0800, Dave Hansen wrote:
>> For what it's worth, I'm pretty convinced that the numbers folks put in
>> the SLIT tables are, at best, horribly inconsistent from system to
>> system.  At worst, they're utter fabrications not linked at all to the
>> reality of the actual latencies.
> 
> You mean the reported distances should probably be bigger on this
> particular machine?

Yeah, or smaller on the others that made us switch zone_reclaim_mode at
the place where we do.

> But even when correct, zone_reclaim_mode might not be the best
> predictor.  Just because it's not worth yet to invest direct reclaim
> efforts to stay local does not mean that remote references are free.
> 
> I'm currently running some tests with the below draft to see if this
> would still leave us with enough fairness.  Does the patch restore
> performance even with zone_reclaim_mode disabled?

Yeah, that at least works for the one test where it's been causing the
most trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
