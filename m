From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Fri, 27 Jun 2003 17:17:01 +0200
References: <200306250111.01498.phillips@arcor.de> <200306271654.46491.phillips@arcor.de> <25700000.1056726277@[10.10.2.4]>
In-Reply-To: <25700000.1056726277@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306271717.01562.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 June 2003 17:04, Martin J. Bligh wrote:
> Daniel Phillips <phillips@arcor.de> wrote (on Friday, June 27, 2003
> > Some allocation strategies may be statistically more
> > resistiant to fragmentation than others, but no allocator has been
> > invented, or ever will be, that can guarantee that terminal fragmentation
> > will never occur - only active defragmentation can provide such a
> > guarantee.
>
> Whilst I agree with that in principle, it's inevitably expensive. Thus
> whilst we may need to have that code, we should try to avoid using it ;-)

That's exactly the idea.  Active defragmentation is just a fallback to handle  
currently-unhandled corner cases.  A good, efficient allocator that resists 
fragmentation in the first place is still needed.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
