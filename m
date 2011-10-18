Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 85D816B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 04:49:42 -0400 (EDT)
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 18 Oct 2011 09:49:38 +0100
In-Reply-To: <1318575363.11016.8.camel@dagon.hellion.org.uk>
References: <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com>
	 <20111013.163708.1319779926961023813.davem@davemloft.net>
	 <alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com>
	 <20111013.165148.64222593458932960.davem@davemloft.net>
	 <20111013142201.355f9afc.akpm@linux-foundation.org>
	 <1318575363.11016.8.camel@dagon.hellion.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1318927778.16132.52.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, "rientjes@google.com" <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "jaxboe@fusionio.com" <jaxboe@fusionio.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-10-14 at 07:56 +0100, Ian Campbell wrote:
> On Thu, 2011-10-13 at 22:22 +0100, Andrew Morton wrote:
> > Looks OK to me.  I'm surprised we don't already have such a thing.
> > 
> > Review comments:
> > 
> > 
> > > +struct page_frag {
> > > +	struct page *page;
> > > +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
> > 
> > It does add risk that people will add compile warnings and bugs by
> > failing to consider or test the other case.
> >
> > We could reduce that risk by doing
> > 
> >    #if (PAGE_SIZE >= 65536)
> > 
> > but then the 32-bit version would hardly ever be tested at all.
> 
> Indeed. The first variant has the benefit that most 32-bit arches will
> test one case and most 64-bit ones the other.
> 
> Perhaps the need to keep this struct small is not so acute as it is for
> the skb_frag_t I nicked it from and just using __u32 unconditionally is
> sufficient?

I wasn't sure what to do here so I left it as it was, so the only change
here is s/page_offset/offset/. Switching to a u32 only version is
something we can easily do in the future if this scheme turns out to be
problematic.

Ian.

8<---------------------------------------------------------------
