Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA05351
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 21:25:36 -0500
Date: Tue, 26 Jan 1999 03:22:56 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-28 - new nr_freeable_pages
In-Reply-To: <Pine.LNX.3.96.990121210148.2760B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990126024536.199A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Nimrod Zimerman <zimerman@deskmail.com>, John Alvord <jalvo@cloud9.net>, "Stephen C. Tweedie" <sct@redhat.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Ben McCann <bmccann@indusriver.com>"Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 1999, Andrea Arcangeli wrote:

> I have a new arca-vm-28. I don't have time to comment the changes right
> now, but I would like if you could try it and feedback. This is not
> intended to be good in low memory system, it _could_ work fine also with
> low mem, but I don't know...

I've done some further changes. nr_freeable_pages is still there (since
worked fine so far). But the new code should be far more friendly in low
memory. I am doing everything in 32 Mbyte (as some month ago by default
btw ;) to force me to test the new code ;).

This new code will not give a swapout raw speed as the previous one but
looks far more sane for low memory conditions. The old code was extreme,
the best to half the swapout time and to get the best numbers, but too
much aggressive to use the machine for doing other tasks at the same time
in low memory.

I would like to hear comments if somebody will try it. If you care about
low memory machines please try it and let me know.

ftp://e-mind.com/pub/linux/arca-tree/2.2.0-pre9_arca-3.gz

Now it's really time to sleep for me...

Ah forget to tell, if the size of the cache looks too high or too low,
feel free to decrease or increase the first value of /proc/sys/vm/pager

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
