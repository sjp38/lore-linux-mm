Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5802C6B007D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 04:17:46 -0500 (EST)
Subject: Re: GFP_ATOMIC versus GFP_NOWAIT
From: Andi Kleen <andi@firstfloor.org>
References: <e9c3a7c20911121728n647ab121l7f7c5827afdac887@mail.gmail.com>
Date: Fri, 13 Nov 2009 10:17:36 +0100
In-Reply-To: <e9c3a7c20911121728n647ab121l7f7c5827afdac887@mail.gmail.com> (Dan Williams's message of "Thu, 12 Nov 2009 18:28:18 -0700")
Message-ID: <87k4xuu6kv.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> Looking through the tree it seems that almost all drivers that need to
> allocate memory in atomic contexts use GFP_ATOMIC.  I have been asking
> dmaengine device driver authors to switch their atomic allocations to
> GFP_NOWAIT.  The rationale being that in most cases a dma device is
> either offloading an operation that will automatically fallback to
> software when the descriptor allocation fails, or we can simply poll
> and wait for the dma device to release some in use descriptors.  So it
> does not make sense to grab from the emergency pools when the result
> of an allocation failure is some additional cpu overhead.  Am I
> correct in my nagging, and should this idea be spread outside of
> drivers/dma/ to cut down on GFP_ATOMIC usage, or is this not a big
> issue?

It's probably hard to find a good global priority order between
the various allocators, depending on how much the fallback costs. 
But in principle it sounds like a good idea.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
