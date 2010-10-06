Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E11D6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:52:29 -0400 (EDT)
Date: Wed, 6 Oct 2010 11:52:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101006164326.GB17987@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1010061151470.31538@router.home>
References: <20101005185725.088808842@linux.com> <87fwwjha2u.fsf@basil.nowhere.org> <alpine.DEB.2.00.1010061057160.31538@router.home> <20101006162547.GA17987@basil.fritz.box> <alpine.DEB.2.00.1010061133210.31538@router.home>
 <20101006164326.GB17987@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> > The shared caches are not per node but per sharing domain (l3).
>
> That's the same at least on Intel servers.

Only true for  recent intel servers. My old Dell 1950 has sharing domains
for each 2 cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
