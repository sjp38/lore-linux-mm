Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E79AE6B004F
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 15:24:07 -0400 (EDT)
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20090817191250.GA1816@infradead.org>
References: <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>
	 <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca>
	 <1250344518.4159.4.camel@mulgrave.site>
	 <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>
	 <20090816083434.2ce69859@infradead.org>
	 <1250437927.3856.119.camel@mulgrave.site>
	 <20090816165943.GA26983@infradead.org>
	 <1250517372.3844.3.camel@mulgrave.site>
	 <20090817141038.GB11966@parisc-linux.org>
	 <20090817191250.GA1816@infradead.org>
Content-Type: text/plain
Date: Mon, 17 Aug 2009 19:24:02 +0000
Message-Id: <1250537042.7858.46.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-08-17 at 15:12 -0400, Christoph Hellwig wrote:
> On Mon, Aug 17, 2009 at 08:10:38AM -0600, Matthew Wilcox wrote:
> > On Mon, Aug 17, 2009 at 08:56:12AM -0500, James Bottomley wrote:
> > > The testing was initially done to see if the initial maximal discard
> > > proposal from LSF09 was a viable approach (which it wasn't given the
> > > time taken to UNMAP).
> > 
> > It would be nice if that feedback could be made public instead of it
> > leaking out in dribs and drabs like this.
> 
> Yeah, I don't remember hearing about anything like this either.

Well you were both in #storage when it got discussed on 4 May.  However,
I'm hopeful that the array vendors will make a more direct statement of
the capabilities shortly.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
