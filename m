Date: Mon, 17 Oct 2005 12:36:01 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-ID: <20051017113601.GA25434@infradead.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com> <20051017113131.GA30898@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051017113131.GA30898@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Greg KH <greg@kroah.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com, Dave Hansen <haveblue@us.ibm.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 17, 2005 at 06:31:31AM -0500, Robin Holt wrote:
> On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> > On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > > +EXPORT_SYMBOL(get_one_pte_map);
> > 
> > EXPORT_SYMBOL_GPL() ?
> 
> Not sure why it would fall that way.  Looking at the directory,
> I get:

This is a very lowlevel export for things that poke deep into VM
internals, so _GPL makes sense.  In fact not allowing modular builds
of the mspec driver might make even more sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
