Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva> <200004261433.HAA13894@pizda.ninka.net>
From: Andi Kleen <ak@suse.de>
Date: 26 Apr 2000 18:31:50 +0200
In-Reply-To: "David S. Miller"'s message of "26 Apr 2000 16:48:13 +0200"
Message-ID: <oupbt2wombt.fsf@pigdrop.muc.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> writes:
> 
> See?  The global LRU scheme dynamically figures out what page usage is
> like, it doesn't need to classify processes in a certain way, because
> the per-page reference and dirty state will drive the page liberation
> to just do the right thing.

But is that still fair ? A memory hog could rapidly allocate and
dirty pages, killing the small innocent daemon which just needs to
get some work done.
At least the FreeBSD code i have here has a way to limit maximum
swapout per process and increase it based on the resident pages rlimit.
Linux with your new dancing scheme will probably need this too.


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
