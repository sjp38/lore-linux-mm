Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA12357
	for <linux-mm@kvack.org>; Sat, 16 Jan 1999 11:50:36 -0500
Date: Sat, 16 Jan 1999 17:37:51 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <Pine.LNX.3.96.990116141939.701A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990116173515.219A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nimrod Zimerman <zimerman@deskmail.com>
Cc: Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jan 1999, Andrea Arcangeli wrote:

> On Sat, 16 Jan 1999, Nimrod Zimerman wrote:
> 
> > Personally, I don't like the way the pager works. It is too magical. Change
> > 'priority', and it might work better. Why? Because. I much preferred the old
> > approach, of being able to simply tell the cache (and buffers, though I
> > don't see this unless I explicitly try to enlarge it) to *never*, *ever* grow
> > over some arbitrary limit. This is far better for smaller machines, at
> > least as far as I can currently see.
> 
> Setting an high limit for the cache when we are low memory is easy doable.
> Comments from other mm guys?

Please try out arca-vm-22. You can set the percentage of the cache
(buffer+filecache+swapcache) that your system will get close when you'll
be low on memory. The cache percentage is tunable via the second number in
the sysctl `.../sys/vm/pager`.

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre7-arca-VM-22

Let me know if it's what you like.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
