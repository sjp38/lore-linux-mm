Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB4675F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 05:35:45 -0400 (EDT)
Date: Wed, 8 Apr 2009 11:38:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-ID: <20090408093834.GJ17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407150958.BA68F1D046D@basil.firstfloor.org> <20090407221421.890f27a6.akpm@linux-foundation.org> <20090408062441.GF17934@one.firstfloor.org> <20090408000018.9567a5fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090408000018.9567a5fa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 08, 2009 at 12:00:18AM -0700, Andrew Morton wrote:
> On Wed, 8 Apr 2009 08:24:41 +0200 Andi Kleen <andi@firstfloor.org> wrote:
> 
> > On Tue, Apr 07, 2009 at 10:14:21PM -0700, Andrew Morton wrote:
> > > On Tue,  7 Apr 2009 17:09:58 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:
> > > 
> > > > Poisoned pages need special handling in the VM and shouldn't be touched 
> > > > again. This requires a new page flag. Define it here.
> > > 
> > > I wish this patchset didn't change/abuse the well-understood meaning of
> > > the word "poison".
> > 
> > Sorry, that's the terminology on the hardware side.
> > 
> > If there's much confusion I could rename it HwPoison or somesuch?
> 
> I understand that'd be a PITA but I suspect it would be best,
> long-term.  Having this conflict in core MM is really pretty bad.

Ok. I'll rename it to HWPoison().

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
