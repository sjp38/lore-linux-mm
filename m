Subject: Re: [PATCH] swap_state.c thinko
References: <Pine.LNX.4.31.0104091316500.9383-100000@penguin.transmeta.com>
From: James Antill <james@and.org>
Content-Type: text/plain; charset=US-ASCII
Date: 10 Apr 2001 17:07:21 -0400
In-Reply-To: Linus Torvalds's message of "Mon, 9 Apr 2001 13:32:41 -0700 (PDT)"
Message-ID: <nnae5ompkm.fsf@code.and.org>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 9 Apr 2001, Alan Cox wrote:
> >
> > Given that strict address space management is not that hard would you
> > accept patches to allow optional non-overcommit in 2.5
> 
> I really doubt anybody wants to use a truly non-overcommit system.
> 
> It would basically imply counting every single vma that is privately
> writable, and assuming it becomes totally non-shared.
> 
> Try this on your system as root:
> 
> 	cat /proc/*/maps | grep ' .w.p '
> 
> and see how much memory that is.
> 
> On my machine, running X, that's about 53M with just a few windows open if
> I did my script right. It grew to 159M when starting StarOffice.

 Disk space is cheap(tm), in comparison to a couple of years ago I
have more disk space than $DIETY.

# cat /proc/swaps 
Filename			Type		Size	Used	Priority
/dev/hda3                       partition	979956	0	1
/dev/sda2                       partition	976888	21524	4
/dev/sdb1                       partition	976872	21452	4

 If I could have a sysctl for non-overcommit[1], I'd be pretty
happy. I'd imagine that a _lot_ of people in the server space would
prefer non-overcommit.

[1] Assuming that it doesn't kill performance by allocating non shared
mappings, or chunks of swap etc. Ie. it just knows that it can
allocate swap when it needs it later on.

-- 
# James Antill -- james@and.org
:0:
* ^From: .*james@and\.org
/dev/null
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
