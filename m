Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA28240
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 02:03:33 -0500
Date: Sun, 10 Jan 1999 23:02:47 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: testing/pre-7 and do_poll()
In-Reply-To: <19990111015958.E3767@perlsupport.com>
Message-ID: <Pine.LNX.3.95.990110225652.1997J-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chip Salzenberg <chip@perlsupport.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 11 Jan 1999, Chip Salzenberg wrote:
> > 
> > Hint: HZ is a define - not 100.
> > You just ended up dividing by zero on certain architectures.
> 
> I didn't think HZ ranged over 1000 in practice, else of course I would
> not have written the above.

I made the same assumption wrt usecs (notice how I myself would divide by
zero on any architecture where HZ is over 1000000).

Right now, HZ is 100 on most architectures, with alpha being the exception
at 1024. Some of the PC speaker patches used to have HZ at 8192 even on a
PC, although later versions scaled it down (and just internally used a
timer tick happening at 8kHz, leaving HZ at 100).

With modern machines, 100Hz is just peanuts, and a HZ in the kilohertz
certainly makes sense - and allows for nicer granularity for a lot of
things. So far, megahertz are still far in the future, but maybe I some
day will have to remove even that assumption. Unlikely to be a problem in
my lifetime, but hey, I can hope (whether due to a long life or really
fast CPU's, I don't care ;) 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
