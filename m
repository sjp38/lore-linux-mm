Date: Sun, 19 Aug 2001 03:02:38 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819030238.U1719@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com> <20010819023548.P1719@athlon.random> <20010819025314.R1719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819025314.R1719@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 02:53:14AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 19, 2001 at 02:53:14AM +0200, Andrea Arcangeli wrote:
> I don't think it's a bug so I don't feel the need to change it. The
> expand_stack can only run with the semaphore acquired at worse in read
> mode so it cannot race.

Actually the locking is a bit subtle so I think it needs a further
explanation, everybody but expand_stack is playing with the vm_pgoff
with the write semaphore acquired.

The only ones playing with vm_pgoff with only the read semaphore
acquired is expand_stack and it serialize against itself with the
spinlock.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
