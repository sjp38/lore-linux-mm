Date: Thu, 27 Oct 2005 11:20:54 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027112054.10e945ae.akpm@osdl.org>
In-Reply-To: <20051027151123.GO5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

err, guys.

Andrea Arcangeli <andrea@suse.de> wrote:
>
> ...
>
> tmpfs (the short term big need of this feature).
> 
> ...
>
> Freeing swap entries is the most important thing and at the same time
> the most complex in the patch (that's why the previous MADV_DISCARD was
> so simple ;).
> 

I think there's something you're not telling us!

googling MADV_DISCARD comes up with basically nothing.  MADV_TRUNCATE comes
up with precisely nothing.

Why does tmpfs need this feature?  What's the requirement here?  Please
spill the beans ;)


Comment on the patch: doing it via madvise sneakily gets around the
problems with partial-page truncation (we don't currently have a way to
release anything but the the tail-end of a page's blocks).

But if we start adding infrastructure of this sort people are, reasonably,
going to want to add sys_holepunch(fd, start, len) and it's going to get
complexer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
