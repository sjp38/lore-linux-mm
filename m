Date: Thu, 31 May 2007 11:35:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180636096.5091.125.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705311130010.11008@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
 <1180544104.5850.70.camel@localhost>  <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
 <1180636096.5091.125.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007, Lee Schermerhorn wrote:

> > It seems that you are creating some artificial problems here.
> 
> Christoph:  Let me assume you, I'm not persisting in this exchange
> because I'm enjoying it.  Quite the opposite, actually.  However, like
> you, my employer asks me to address our customers' requirements.  I'm
> trying to understand and play within the rules of the community.  I
> attempted this documentation patch to address what I saw as missing
> documentation and to provide context for further discussion of my patch
> set.  

Could you explain to us what kind of user scenario you are addressing? We 
have repeatedly asked you for that information. I am happy to hear that 
there is an actual customer requirement.

> My point was that the description of MPOL_DEFAULT made reference to the
> zonelists built at boot time, to distinguish them from the custom
> zonelists built for an MPOL_BIND.  Since the zonelist reorder patch
> hasn't made it out of Andrew's tree yet, I didn't want to refer to it
> this round of the doc.  If it makes it into the tree, I had planned say
> something like:  "at boot time or on request".  I should probably add
> "or on memory hotplug".

Hmmm... The zonelists for MPOL_BIND are never rebuilt by Kame-san's 
patches. That  is a concern.

> But, after I see what gets accepted into the man pages that I've agreed
> to update, I'll consider dropping this section altogether.  Maybe the
> entire document.

I'd be very thankful if you could upgrade the manpages. Andi has some 
patches from me against numactl pending that include manpage 
updatess. I can forward that too you.

> > page cache pages are subject to a tasks memory policy regardless of how we 
> > get to the page cache page. I think that is pretty consistent.
> 
> Oh, it's consistent, alright.  Just not pretty [;-)] when it's not what
> the application wants.

I sure hope that we can at some point figure out what your applications is 
doing. Its been a hard road to that information so far.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
