Date: Mon, 7 Jul 2003 11:00:14 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307060414.34827.phillips@arcor.de>
Message-ID: <Pine.LNX.4.53.0307071042470.743@skynet>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060010.26002.phillips@arcor.de>
 <20030706012857.GA29544@mail.jlokier.co.uk> <200307060414.34827.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jul 2003, Daniel Phillips wrote:

> > > What are you going to do if you have one
> > > application you want to take priority, re-nice the other 50?
> >
> > Is that effective?  It might be just the trick.
>
> Point.
>

Alternatively, how about using PAM to grant the CAP_SYS_NICE capability to
known interactive users that require it. Presumably the number of users
that require it is very small (in the case of the music player, only one)
so it wouldn't be a major security issue.

There is something along these lines at http://www.pamcap.org but it
requires some patching to the kernel (only available against 2.4.18
currently) to inherit capabilities across exec and, from what I gather at
a quick glance, to allow capabilities to be set for a process group.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
