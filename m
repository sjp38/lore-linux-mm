Date: Wed, 18 Jul 2001 19:48:38 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.21.0107172337340.1015-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0107181940400.1080-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2001, Hugh Dickins wrote:
> 
> ftp://ftp.veritas.com/linux/larpage-2.4.6.patch.bz2
> 
> is the promised Large PAGE_SIZE patch against 2.4.6.  If you'd like
> to try these large pages, you'll have to edit include/asm-i386/page.h
> PAGE_MMUSHIFT from 0 to 1 or 2 or 3: no configuration yet.  There's
> a sense in which the patch is now complete, but I'll probably be
> ashamed of that claim tomorrow (several of the drivers haven't even
> got compiled yet, much more remains untested).  I'll update to 2.4.7
> once it appears, but probably have to skip the -pres.

Sorry for the noise, but somewhere between send and receive,
the all-important first line of yesterday's mail moved itself from
mail body to mail header.  I guess it's a bad idea to start off with
an ftp path (or "token:"?), so let's try it this way instead.

ftp://ftp.veritas.com/linux/larpage-2.4.6.patch.bz2

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
