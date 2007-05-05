Date: Sat, 5 May 2007 10:43:00 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Message-ID: <20070505094300.GA9592@infradead.org>
References: <20070504102651.923946304@chello.nl> <20070504.122716.31641374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070504.122716.31641374.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch, James.Bottomley@SteelEye.com, michaelc@cs.wisc.edu, akpm@linux-foundation.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

On Fri, May 04, 2007 at 12:27:16PM -0700, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Fri, 04 May 2007 12:26:51 +0200
> 
> > There is a fundamental deadlock associated with paging;
> 
> I know you'd really like people like myself to review this work, but a
> set of 40 patches is just too much to try and digest at once
> especially when I have other things going on.  When I have lots of
> other things already on my plate, when I see a huge patch set like
> this I have to just say "delete" because I don't kid myself since
> I know I'll never get to it.
> 
> Sorry there's now way I can review this with my current workload.

There also quite alot of only semi-related thing in there.  It would
be much better to only do the network stack and iscsi parts first
and leave nfs out for a while.  Especially as the former are definitively
useful while I strongly doubt that for swap over nfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
