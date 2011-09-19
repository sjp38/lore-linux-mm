Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7B89000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 13:52:01 -0400 (EDT)
Received: by vws7 with SMTP id 7so9974442vws.35
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 10:51:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110919173539.GA3751@albatros>
References: <20110910164134.GA2442@albatros>
	<20110914192744.GC4529@outflux.net>
	<20110918170512.GA2351@albatros>
	<CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
	<20110919144657.GA5928@albatros>
	<CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
	<20110919155718.GB16272@albatros>
	<CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
	<20110919161837.GA2232@albatros>
	<CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
	<20110919173539.GA3751@albatros>
Date: Mon, 19 Sep 2011 20:51:59 +0300
Message-ID: <CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Sep 19, 2011 at 8:35 PM, Vasiliy Kulikov <segoon@openwall.com> wrot=
e:
>> Yes, but there's no way for users to know where the allocations came fro=
m
>> if you mix them up with other kmalloc-128 call-sites. That way the numbe=
r
>> of private files will stay private to the user, no? Doesn't that give yo=
u even
>> better protection against the infoleak?
>
> No, what it gives us is an obscurity, not a protection. =A0I'm sure it
> highly depends on the specific situation whether an attacker is able to
> identify whether the call is from e.g. ecryptfs or from VFS. =A0Also the
> correlation between the number in slabinfo and the real private actions
> still exists.

How is the attacker able to identify that we kmalloc()'d from ecryptfs or
VFS based on non-root /proc/slabinfo when the slab allocator itself does
not have that sort of information if you mix up the allocations? Isn't this
much stronger protection especially if you combine that with /proc/slabinfo
restriction?

                                  Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
