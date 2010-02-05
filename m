Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 00BAD6B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 15:22:25 -0500 (EST)
Subject: Re: [PATCH] [0/4] SLAB: Fix a couple of slab memory hotadd issues
From: Andi Kleen <andi@firstfloor.org>
References: <201002031039.710275915@firstfloor.org>
	<alpine.DEB.2.00.1002051316350.25989@router.home>
Date: Fri, 05 Feb 2010 21:22:21 +0100
In-Reply-To: <alpine.DEB.2.00.1002051316350.25989@router.home> (Christoph Lameter's message of "Fri, 5 Feb 2010 13:19:48 -0600 (CST)")
Message-ID: <87636bv3eq.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> On Wed, 3 Feb 2010, Andi Kleen wrote:
>
>> This fixes various problems in slab found during memory hotadd testing.
>
> It changes the bootstrap semantics. The requirement was so far that slab
> initialization must be complete before slab operations can be used.

The problem is that slab itself uses slab it initialize itself.

> This patchset allows such use before bootstrap on a node is complete and
> also allows the running of cache reaper before bootstrap is done.
>
> I have a bad feeling that this could be the result of Pekka's changes to
> the bootstrap.

Not sure I fully follow what you're saying.

Are you saying this is a regression fix after all?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
