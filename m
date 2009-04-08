Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5BD5F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:03:45 -0400 (EDT)
Date: Wed, 8 Apr 2009 00:00:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-Id: <20090408000018.9567a5fa.akpm@linux-foundation.org>
In-Reply-To: <20090408062441.GF17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	<20090407150958.BA68F1D046D@basil.firstfloor.org>
	<20090407221421.890f27a6.akpm@linux-foundation.org>
	<20090408062441.GF17934@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 08:24:41 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> On Tue, Apr 07, 2009 at 10:14:21PM -0700, Andrew Morton wrote:
> > On Tue,  7 Apr 2009 17:09:58 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > Poisoned pages need special handling in the VM and shouldn't be touched 
> > > again. This requires a new page flag. Define it here.
> > 
> > I wish this patchset didn't change/abuse the well-understood meaning of
> > the word "poison".
> 
> Sorry, that's the terminology on the hardware side.
> 
> If there's much confusion I could rename it HwPoison or somesuch?

I understand that'd be a PITA but I suspect it would be best,
long-term.  Having this conflict in core MM is really pretty bad.

> > > The page flags wars seem to be over, so it shouldn't be a problem
> > > to get a new one. I hope.
> > 
> > They are?  How did it all get addressed?
> 
> Allowing 64bit to use more and using [V]SPARSEMAP to limit flags
> use for zones. I think.

Nobody ever seems to be able to work out how many we actually have
left.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
