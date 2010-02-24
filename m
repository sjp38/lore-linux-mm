Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 50EFE6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 02:39:51 -0500 (EST)
Date: Wed, 24 Feb 2010 18:39:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224073940.GJ16175@discord.disaster>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100224061247.GA8421@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 02:12:47PM +0800, Wu Fengguang wrote:
> On Wed, Feb 24, 2010 at 01:22:15PM +0800, Dave Chinner wrote:
> > What I'm trying to say is that while I agree with your premise that
> > a 7.8MB readahead window is probably far larger than was ever
> > intended, I disagree with your methodology and environment for
> > selecting a better default value.  The default readahead value needs
> > to work well in as many situations as possible, not just in perfect
> > 1:1 client/server environment.
> 
> Good points. It's imprudent to change a default value based on one
> single benchmark. Need to collect more data, which may take time..

Agreed - better to spend time now to get it right...

> > > It sounds silly to have
> > > 
> > >         client_readahead_size > server_readahead_size
> > 
> > I don't think it is  - the client readahead has to take into account
> > the network latency as well as the server latency. e.g. a network
> > with a high bandwidth but high latency is going to need much more
> > client side readahead than a high bandwidth, low latency network to
> > get the same throughput. Hence it is not uncommon to see larger
> > readahead windows on network clients than for local disk access.
> 
> Hmm I wonder if I can simulate a high-bandwidth high-latency network
> with e1000's RxIntDelay/TxIntDelay parameters..

I think netem is the blessed method of emulating different network
behaviours. There's a howto+faq for setting it up here:

http://www.linuxfoundation.org/collaborate/workgroups/networking/netem

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
