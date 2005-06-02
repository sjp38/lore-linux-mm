Date: Thu, 2 Jun 2005 10:49:50 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
In-Reply-To: <429E20B6.2000907@austin.ibm.com>
Message-ID: <Pine.LNX.4.58.0506021049270.4112@skynet>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jun 2005, Joel Schopp wrote:

>
> > -    struct free_area *area;
> >      struct page *buddy;
> > -
> > +
>
> ...
>
> >      }
> > +
> >      spin_unlock_irqrestore(&zone->lock, flags);
> > -    return allocated;
> > +    return count - allocated;
> >  }
> >  +
> > +
>
> Other than the very minor whitespace changes above I have nothing bad to say
> about this patch.  I think it is about time to pick in up in -mm for wider
> testing.
>

Thanks. I posted a V13 without the whitespace damage

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
