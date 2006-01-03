Date: Tue, 3 Jan 2006 10:06:52 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] Event counters [1/3]: Basic counter functionality
Message-ID: <20060103120652.GB5288@dmt.cnet>
References: <20051220235733.30925.55642.sendpatchset@schroedinger.engr.sgi.com> <20051231064615.GB11069@dmt.cnet> <43B63931.6000307@yahoo.com.au> <20051231202602.GC3903@dmt.cnet> <20060102214016.GA13905@dmt.cnet> <1136265106.5261.34.camel@npiggin-nld.site> <20060103101106.GA3435@dmt.cnet> <43BA7A73.6070407@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43BA7A73.6070407@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 04, 2006 at 12:21:55AM +1100, Nick Piggin wrote:
> Marcelo Tosatti wrote:
> >On Tue, Jan 03, 2006 at 04:11:46PM +1100, Nick Piggin wrote:
> >
> 
> >>I guess I was hoping to try to keep it simple, and just have two
> >>variants, the __ version would require the caller to do the locking.
> >
> >
> >I see - one point is that the two/three underscore versions make
> >it clear that preempt is required, though, but it might be a bit
> >over-complicated as you say.
> >
> >Well, its up to you - please rearrange the patch as you wish and merge
> >up?
> >
> 
> OK I will push it upstream - thanks!
> 
> We can revisit details again when some smoke clears from the
> coming 2.6.16 merge cycle?

Sure - we can also go further and the optimize operations on the
remaining counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
