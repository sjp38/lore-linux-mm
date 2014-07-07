Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 760FA6B0038
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 19:05:01 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so1746697wgh.32
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 16:05:00 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id n9si43195429wiz.23.2014.07.07.16.05.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 16:05:00 -0700 (PDT)
Date: Tue, 8 Jul 2014 01:04:59 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: fallout of 16K stacks
Message-ID: <20140707230459.GF18735@two.firstfloor.org>
References: <20140707223001.GD18735@two.firstfloor.org>
 <53BB240C.30400@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BB240C.30400@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <andi@firstfloor.org>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 03:49:48PM -0700, H. Peter Anvin wrote:
> On 07/07/2014 03:30 PM, Andi Kleen wrote:
> > 
> > Since the 16K stack change I noticed a number of problems with
> > my usual stress tests. They have a tendency to bomb out
> > because something cannot fork.
> 
> As in ENOMEM or does something worse happen?

EAGAIN, then the workload stops. For an overnight stress
test that's pretty catastrophic. It may have killed some stuff
with the OOM killer too.

> > - AIM7 on a dual socket socket system now cannot reliably run 
> >> 1000 parallel jobs.
> 
> ... with how much RAM?

This system has 32G

> > - LTP stress + memhog stress in parallel to something else
> > usually doesn't survive the night.
> > 
> > Do we need to strengthen the memory allocator to try
> > harder for 16K?
> 
> Can we even?  The probability of success goes down exponentially in the
> order requested.  Movable pages can help, of course, but still, there is
> a very real cost to this :(

I hope so. In the worst case just try longer.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
