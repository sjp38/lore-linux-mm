Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7A44F9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 13:51:17 -0400 (EDT)
Date: Mon, 19 Sep 2011 12:51:10 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to
 /proc/slabinfo
In-Reply-To: <20110919173539.GA3751@albatros>
Message-ID: <alpine.DEB.2.00.1109191249450.10968@router.home>
References: <20110910164134.GA2442@albatros> <20110914192744.GC4529@outflux.net> <20110918170512.GA2351@albatros> <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com> <20110919144657.GA5928@albatros> <CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
 <20110919155718.GB16272@albatros> <CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com> <20110919161837.GA2232@albatros> <CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com> <20110919173539.GA3751@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 19 Sep 2011, Vasiliy Kulikov wrote:

> > > kmalloc() is still visible in slabinfo as kmalloc-128 or so.
> >
> > Yes, but there's no way for users to know where the allocations came from
> > if you mix them up with other kmalloc-128 call-sites. That way the number
> > of private files will stay private to the user, no? Doesn't that give you even
> > better protection against the infoleak?
>
> No, what it gives us is an obscurity, not a protection.  I'm sure it
> highly depends on the specific situation whether an attacker is able to
> identify whether the call is from e.g. ecryptfs or from VFS.  Also the
> correlation between the number in slabinfo and the real private actions
> still exists.

IMHO a restriction of access to slab statistics is reasonable in a
hardened environment. Make it dependent on CONFIG_SECURITY or some such
thing?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
