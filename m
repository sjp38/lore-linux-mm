Received: from frodo.biederman.org (IDENT:root@frodo [10.0.0.2])
	by flinx.biederman.org (8.9.3/8.9.3) with ESMTP id VAA11780
	for <linux-mm@kvack.org>; Mon, 8 Jan 2001 21:41:41 -0700
Subject: Re: Linux-2.4.x patch submission policy
References: <Pine.LNX.4.21.0101081837520.21675-100000@duckman.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 08 Jan 2001 21:00:39 -0700
In-Reply-To: Rik van Riel's message of "Mon, 8 Jan 2001 18:40:21 -0200 (BRDT)"
Message-ID: <m17l45idco.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > vendors who think 2.4 VM performance isn't good enough for
> > > them ;)
> > 
> > Hmm, could you instead follow Andreas approach and have a
> > directory with little patches, that do _exactly_ one thing and a
> > file along to describe what is related, dependend and what each
> > patch does?
> 
> I wasn't aware Andrea switched the way he stored his patches
> lately ;)
> 
> But seriously, you're right that this is a good thing. I'll
> work on splitting out my patches and documenting what each
> part does.
> 
> (but not now, I'm headed off for Australia ... maybe I can
> split out the patches on my way there and cvs commit when
> I'm there)
> 
> OTOH, the advantage of having a big patch means that it's
> easier for me to get people to test all of the things I
> have. Guess I'll need to find a way to easily get both the
> small and the big patches ;)

What we have done with dosemu is provide a tar ball that unpacks
it's patches into a subdirectory, and a script that applies all of
the patches, and deletes the new useless subdirectory.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
