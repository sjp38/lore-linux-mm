Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23676
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:42:20 -0500
Date: Sun, 10 Jan 1999 21:41:57 GMT
Message-Id: <199901102141.VAA01398@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990109193238.2615A-100000@laser.bogus>
References: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
	<Pine.LNX.3.96.990109193238.2615A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 9 Jan 1999 19:41:36 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Sat, 9 Jan 1999, Linus Torvalds wrote:
>> refuse to touch an inode that is busy is a sure way to allow people to

> What do you mean for busy? What about refusing filemap_write_page() in
> filemap_swapout() only if
> !atomic_count(&vma->vm_file->d_entry->d_inode->i_sem.count)?

The problem with that is what happens if we have a large, active
write-mapped file with lots of IO activity on it; we become essentially
unable to swap that file out.  That has really nasty VM death
implications for things like databases.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
