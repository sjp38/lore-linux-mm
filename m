Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA13867
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 13:59:22 -0500
Date: Sat, 9 Jan 1999 19:41:36 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990109193238.2615A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jan 1999, Linus Torvalds wrote:

> refuse to touch an inode that is busy is a sure way to allow people to

What do you mean for busy? What about refusing filemap_write_page() in
filemap_swapout() only if
!atomic_count(&vma->vm_file->d_entry->d_inode->i_sem.count)?

That way other no-fs path could still put the dirty pages of the shared
mapping on disk. Today I had a really little time to play with Linux due
OFFTOPIC University studies (I should never play with Linux :() so I had
not time to try out this my new idea, so maybe I am missing something... 

Other my thoughts about the topic are: maybe do the inode sempahore
recursive could be better anyway so better to do that now? I don't know
what does it mean recursive ;), I guess like lock_kernel(). But that way
we would be not sure to preserve data integrity if the same process would
do crazy things, right now we would "only" deadlock in such case. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
