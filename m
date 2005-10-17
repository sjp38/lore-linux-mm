Date: Mon, 17 Oct 2005 06:47:30 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-ID: <20051017114730.GC30898@lnx-holt.americas.sgi.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com> <20051017113131.GA30898@lnx-holt.americas.sgi.com> <1129549312.32658.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1129549312.32658.32.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Greg KH <greg@kroah.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 17, 2005 at 01:41:52PM +0200, Dave Hansen wrote:
> On Mon, 2005-10-17 at 06:31 -0500, Robin Holt wrote:
> > On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> > > On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > > > +EXPORT_SYMBOL(get_one_pte_map);
> > > 
> > > EXPORT_SYMBOL_GPL() ?
> > 
> > Not sure why it would fall that way.  Looking at the directory,
> > I get:
> 
> Most of the VM stuff in those directories that you're referring to are
> old, crusty exports, from the days before _GPL.  We've left them to be
> polite, but if many of them were recreated today, they'd certainly be
> _GPL.

I got a little push from our internal incident tracking system for
this being a module.  _GPL it will be.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
