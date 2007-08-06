From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 11:43:25 -0700
References: <20070806102922.907530000@chello.nl> <200708061121.50351.phillips@phunq.net> <1186425063.11797.80.camel@lappy>
In-Reply-To: <1186425063.11797.80.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061143.25583.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 11:31, Peter Zijlstra wrote:
> > I agree that the reserve pool should be per-node in the end, but I
> > do not think that serves the interest of simplifying the initial
> > patch set.  How about a numa performance patch that adds onto the
> > end of Peter's series?
>
> Trouble with keeping this per node is that all the code dealing with
> the reserve needs to keep per-cpu state, which given that the system
> is really crawling at that moment, seems excessive.

It does.  I was suggesting that Christoph think about the NUMA part, our 
job just to save the world ;-)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
