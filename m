Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EB0DF6B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 17:16:43 -0400 (EDT)
Date: Thu, 22 Jul 2010 14:00:05 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] zcache: page cache compression support
Message-ID: <20100722210005.GC29981@kroah.com>
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org20100722191457.GA13309@kroah.com>
 <a9978c9a-6d85-477e-9962-395208fb5dd4@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9978c9a-6d85-477e-9962-395208fb5dd4@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 12:54:57PM -0700, Dan Magenheimer wrote:
> > From: Greg KH [mailto:greg@kroah.com]
> > Sent: Thursday, July 22, 2010 1:15 PM
> > To: Nitin Gupta
> > Cc: Pekka Enberg; Hugh Dickins; Andrew Morton; Dan Magenheimer; Rik van
> > Riel; Avi Kivity; Christoph Hellwig; Minchan Kim; Konrad Rzeszutek
> > Wilk; linux-mm; linux-kernel
> > Subject: Re: [PATCH 0/8] zcache: page cache compression support
> > 
> > On Fri, Jul 16, 2010 at 06:07:42PM +0530, Nitin Gupta wrote:
> > > Frequently accessed filesystem data is stored in memory to reduce
> > access to
> > > (much) slower backing disks. Under memory pressure, these pages are
> > freed and
> > > when needed again, they have to be read from disks again. When
> > combined working
> > > set of all running application exceeds amount of physical RAM, we get
> > extereme
> > > slowdown as reading a page from disk can take time in order of
> > milliseconds.
> > 
> > <snip>
> > 
> > Given that there were a lot of comments and changes for this series,
> > can
> > you resend them with your updates so I can then apply them if they are
> > acceptable to everyone?
> > 
> > thanks,
> > greg k-h
> 
> Hi Greg --
> 
> Nitin's zcache code is dependent on the cleancache series:
> http://lkml.org/lkml/2010/6/21/411 

Ah, I didn't realize that.  Hm, that makes it something that I can't
take until that code is upstream, sorry.

> The cleancache series has not changed since V3 (other than
> fixing a couple of documentation typos) and didn't receive any
> comments other than Christoph's concern that there weren't
> any users... which I think has been since addressed with the
> posting of the Xen tmem driver code and Nitin's zcache.
> 
> If you are ready to apply the cleancache series, great!
> If not, please let me know next steps so cleancache isn't
> an impediment for applying the zcache series.

I don't know, work with the kernel developers to resolve the issues they
pointed out in the cleancache code and when it goes in, then I can take
these patches.

good luck,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
