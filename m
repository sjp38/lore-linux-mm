Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA10721
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 09:48:08 -0500
Date: Thu, 21 Jan 1999 14:47:31 GMT
Message-Id: <199901211447.OAA01170@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <Pine.LNX.3.96.990119212155.402A-100000@laser.bogus>
References: <Pine.BSF.4.05.9901191505560.2608-100000@earl-grey.cloud9.net>
	<Pine.LNX.3.96.990119212155.402A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, John Alvord <jalvo@cloud9.net>, Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 19 Jan 1999 21:35:33 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> My point is that the algorithm to do something of useful and safe needs an
> objective to reach. The algorithm need to know what has to do. I learn to
> the algorithm what to do, nothing more.

No.  The algorithm should react to the current *load*, not to what it
thinks the ideal parameters should be.  There are specific things you
can do to the VM which completely invalidate any single set of cache
figures.  For example, you can create large ramdisks which effectively
lock large amounts of memory into the buffer cache, and there's nothing
you can do about that.  If you rely on magic numbers to get the
balancing right, then performance simply disappears when you do
something unexpected like that.

This is not supposition.  This is the observed performance of VMs which
think they know how much memory should be allocated for different
purposes.  You cannot say that cache should be larger than or smaller
than a particular value, because only the current load can tell you how
big the cache should be and that load can vary over time.

> I dropped all others bogus percentage levels. So at least my code is
> 6/1 times less Horrible than pre8 (and sctvm) from your `must work
> (and mess) with magic' point of view.

sctvm used figures of (I think) 1% and 100% for the minimum and maximum
buffer/cache values.  In other words, the mechanism was there to let the
user set limits, but it wasn't used by default.

> If I am missing something (again ;) comments are always welcome.

Yes.  Offer the functionality of VM limits, sure.  Relying on it is a
disaster if the user does something you didn't predict.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
