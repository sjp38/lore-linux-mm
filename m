From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Fri, 27 Jun 2003 16:54:46 +0200
References: <200306250111.01498.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet> <23430000.1056725030@[10.10.2.4]>
In-Reply-To: <23430000.1056725030@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306271654.46491.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 June 2003 16:43, Martin J. Bligh wrote:
> The buddy allocator is not a good system for getting rid of fragmentation.

We've talked in the past about throwing out the buddy allocator and adopting 
something more modern and efficient and I hope somebody will actually get 
around to doing that.  In any event, defragging is an orthogonal issue.  Some 
allocation strategies may be statistically more resistiant to fragmentation 
than others, but no allocator has been invented, or ever will be, that can 
guarantee that terminal fragmentation will never occur - only active 
defragmentation can provide such a guarantee.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
