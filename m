Date: Sun, 19 Aug 2001 02:53:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819025314.R1719@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com> <20010819023548.P1719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819023548.P1719@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 02:35:48AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 19, 2001 at 02:35:48AM +0200, Andrea Arcangeli wrote:
> For the vm_pgoff I need to think more about it (quite frankly I never
> thought about expand_stack(), I only thought about the swapper locking
> while doing the "odd" change), if it's a bug I will release a corrected
> mmap-rb-5 in a few hours.  Thanks for raising this issue.

I don't think it's a bug so I don't feel the need to change it. The
expand_stack can only run with the semaphore acquired at worse in read
mode so it cannot race.

However now that you make me to think about this vm_pgoff field I'm
afraid I forgot to update it in the forward merging cases (in the new
code), luckily there are only a few forward merging cases that we have
to do (the backmerging are much more frequent) so it will be trivial to
fix it (and since I only merge anon mappings the bug seems only
theorical and this is probably why I couldn't notice it while doing the
regression testing [but I certainly agree to fix it even if it's
theorical]).

If I'm missing something let me know of course, thanks,

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
