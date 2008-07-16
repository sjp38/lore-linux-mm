From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: xfs bug in 2.6.26-rc9
Date: Wed, 16 Jul 2008 14:12:40 +1000
References: <alpine.DEB.1.10.0807110939520.30192@uplift.swm.pp.se> <200807151617.58329.nickpiggin@yahoo.com.au> <20080715122250.GA15744@infradead.org>
In-Reply-To: <20080715122250.GA15744@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807161412.40893.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Lachlan McIlroy <lachlan@sgi.com>, Mikael Abrahamsson <swmike@swm.pp.se>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 15 July 2008 22:22, Christoph Hellwig wrote:
> > It would be easily possible to do, yes.
>
> What happened to your plans to merge ->nopfn into ->fault?  Beeing
> able to restart page based faults would be a logical fallout from that.

Yeah I guess I should really do that, and you're right it would
work nicely for this.

Actually I have some code but it is not quite as nice as I'd like.
The problem is that we have the generic file fault handler, but not
a generic page mkwrite handler. So we still need some kind of
page_mkwrite aop which the file fault handler can then call if it
exists. It isn't a big problem AFAIKS, but just a bit irritating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
