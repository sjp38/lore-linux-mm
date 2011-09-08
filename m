Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 05944900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 14:41:18 -0400 (EDT)
Date: Thu, 8 Sep 2011 13:41:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: continue to seek slab in node partial if met
 a null page
In-Reply-To: <1315471083.31737.284.camel@debian>
Message-ID: <alpine.DEB.2.00.1109081339360.14787@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <1315362396.31737.151.camel@debian>  <1315363526.31737.164.camel@debian>  <alpine.DEB.2.00.1109070958050.9406@router.home>
 <1315471083.31737.284.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 8 Sep 2011, Alex,Shi wrote:

> > > If it happen, we'd better to skip the full page and to seek next slab in
> > > node partial instead of jump to other nodes.
> >
> > But I agree that the patch can be beneficial if acquire slab ever returns
> > a full page. That should not happen though. Is this theoretical or do you
> > have actual tests that show that this occurs?
>
> I didn't find a real case for this now. So, do you still like to pick up
> this as a defense for future more lockless usage?

I am at a conference and its a bit difficult to see the state of affairs
right now. Lets first defer it until I can see how this would otherwise
impact things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
