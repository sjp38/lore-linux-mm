Date: Tue, 18 Sep 2007 11:58:36 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070918115836.1394a051@twins>
In-Reply-To: <200709172211.26493.phillips@phunq.net>
References: <20070814142103.204771292@sgi.com>
	<200709171728.26180.phillips@phunq.net>
	<170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com>
	<200709172211.26493.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Mike Snitzer <snitzer@gmail.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>, Wouter Verhelst <w@uter.be>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 22:11:25 -0700 Daniel Phillips <phillips@phunq.net>
wrote:


> > I've been using Avi Kivity's patch from some time ago:
> > http://lkml.org/lkml/2004/7/26/68
> 
> Yes.  Ddsnap includes a bit of code almost identical to that, which we wrote independently.  Seems wild and crazy at first blush, doesn't it? But this approach has proved robust in practice, and is to my mind, obviously correct.

I'm so not liking this :-(

Can't we just run the user-space part as mlockall and extend netlink
to work with PF_MEMALLOC where needed?

I did something like that for iSCSI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
