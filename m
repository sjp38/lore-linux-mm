Subject: Re: vm_store patches
References: <Pine.LNX.3.96.990714110014.11342A-100000@mole.spellcast.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 15 Jul 1999 03:13:18 -0500
In-Reply-To: "Benjamin C.R. LaHaise"'s message of "Wed, 14 Jul 1999 11:12:17 -0400 (EDT)"
Message-ID: <m1r9mauy8x.fsf@alogconduit1af.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Benjamin C.R. LaHaise" <blah@kvack.org> writes:

> Hello Eric (and all),
> 
> What's the state of your vm_store patches from the series you posted a
> while back?  There are a couple of things I'd like to play with along
> their lines: using vm_stores for ext2 metadata to make prefetching of
> indirect blocks 'just happen' during truncate, rather than making it
> explicite as would currently be the case.

My machine has been off for about the last month,
I was installing a CD writer and my secondary hard driver controller
ide1 is scrambled, and it scrambled my hard drive.
Backups would have been nice but that's what the CD writer was for. . .

I'll be moving it up to newer kernels in the next while.
Together with some hard thinking about what I really want in the kernel
and what is really useful.

But I need to review 2.3.7 yet.

If you could explain (pseudo code maybe) what you are looking to
do in a little more detail it would certainly help motivate me. :)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
