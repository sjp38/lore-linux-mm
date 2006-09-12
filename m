Date: Tue, 12 Sep 2006 09:37:40 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 00/20] vm deadlock avoidance for NFS, NBD and iSCSI (take
 7)
In-Reply-To: <20060912143049.278065000@chello.nl>
Message-ID: <Pine.LNX.4.64.0609120935110.27779@g5.osdl.org>
References: <20060912143049.278065000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, Rik van Riel <riel@redhat.com>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>


On Tue, 12 Sep 2006, Peter Zijlstra wrote:
> 
> Linus, when I mentioned swap over network to you in Ottawa, you said it was
> a valid use case, that people actually do and want this. Can you agree with
> the approach taken in these patches?

Well, in all honesty, I don't think I really said "valid", but that I said 
that some crazy people want to do it, and that we should try to allow them 
their foibles.

So I'd be nervous to do any _guarantees_. I think that good VM policies 
should make it be something that works in general (the dirty mapping 
limits in particular), but I'd be a bit nervous about anybody taking it 
_too_ seriously. Crazy people are still crazy, they just might be right 
under certain reasonably-well-controlled circumstances.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
