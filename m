Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3A4686B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:49:42 -0500 (EST)
Date: Wed, 24 Feb 2010 09:49:24 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <20100220090154.GB11287@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1002240949140.26771@router.home>
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org>
 <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010, Andi Kleen wrote:

> On Fri, Feb 19, 2010 at 12:22:58PM -0600, Christoph Lameter wrote:
> > On Mon, 15 Feb 2010, Nick Piggin wrote:
> >
> > > I'm just worried there is still an underlying problem here.
> >
> > So am I. What caused the breakage that requires this patchset?
>
> Memory hotadd with a new node being onlined.

That used to work fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
