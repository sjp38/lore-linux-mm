From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14283.53075.795656.291744@dukat.scot.redhat.com>
Date: Tue, 31 Aug 1999 13:49:23 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <37CBB49E.C52C5D99@switchboard.ericsson.se>
References: <Pine.GSO.4.10.9908302023470.15357-100000@mail1.sas.upenn.edu>
	<37CBB49E.C52C5D99@switchboard.ericsson.se>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
Cc: Vladimir Dergachev <vdergach@sas.upenn.edu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 31 Aug 1999 12:55:26 +0200, Marcus Sundberg
<erammsu@kieraypc01.p.y.ki.era.ericsson.se> said:

> But by only re-mapping the framebuffer on demand as Stephen said you
> can avoid repeatedly un-mapping the framebuffer for processes/threads
> that doesn't use it.

Yes.  The biggest problem is that the VM currently has no support for
demand-paging of an entire framebuffer region, and taking a separate
page fault to fault back the mapping of every page in the framebuffer
would be too slow.  As long as we can switch the entire framebuffer in
and out of the mapping rapidly, things aren't too bad.

Even on an SMP box with threads, the overhead is probably acceptable if
we are switching at no more than frame rate.  However, for low latency,
high throughput graphics, I'm guessing we'd be driving the accel engine
a lot faster than that, and we also have the problem that many graphics
operations will require fine interleaving of (and hence fast switching
between) accelerated and framebuffer access.  VM enforcement simply is
not fast enough for this.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
