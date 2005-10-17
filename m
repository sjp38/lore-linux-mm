Date: Mon, 17 Oct 2005 09:05:59 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-ID: <20051017160559.GA315@kroah.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com> <20051017113131.GA30898@lnx-holt.americas.sgi.com> <1129549312.32658.32.camel@localhost> <20051017114730.GC30898@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0510171331090.2993@goblin.wat.veritas.com> <20051017151430.GA2564@lnx-holt.americas.sgi.com> <20051017152034.GA32286@kroah.com> <20051017155605.GB2564@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051017155605.GB2564@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Dave Hansen <haveblue@us.ibm.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Carsten Otte <cotte@de.ibm.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 17, 2005 at 10:56:05AM -0500, Robin Holt wrote:
> On Mon, Oct 17, 2005 at 08:20:34AM -0700, Greg KH wrote:
> > > Would it be reasonable to ask that the current patch be included and
> > > then I work up another patch which introduces a ->nopfn type change
> > > for the -mm tree?
> > 
> > The stuff in -mm is what is going to be in .15, so you have to work off
> > of that patchset if you wish to have something for .15.
> 
> Is everything in the mm/ directory from the -mm tree going into .15 or
> is there a planned subset?  What should I develop against to help ensure
> I match up with the community?

-mm is "the community" :)

But Hugh would have the best answer for this, as he knows what he will
be sending in for .15, so at the least, work off of his patches in
there.

Good luck,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
