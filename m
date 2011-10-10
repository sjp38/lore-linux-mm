Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C8E2F6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:11:09 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add a "struct subpage" type containing a page,
 offset and length
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 17:10:59 +0100
In-Reply-To: <20111010155557.GA15503@infradead.org>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
	 <20111010155557.GA15503@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1318263059.21903.462.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2011-10-10 at 16:55 +0100, Christoph Hellwig wrote:
> On Mon, Oct 10, 2011 at 12:11:33PM +0100, Ian Campbell wrote:
> > A few network drivers currently use skb_frag_struct for this purpose but I have
> > patches which add additional fields and semantics there which these other uses
> > do not want.
> > 
> > A structure for reference sub-page regions seems like a generally useful thing
> > so do so instead of adding a network subsystem specific structure.
> 
> Subpage seems like a fairly bad name.  page_frag would fit into the
> scheme used in a few other places.

ok.

> The brings back the discussion of unifying the various incarnations we
> have of this (biovec, skb frag and there were a few more at times),
> but IIRC one of the sticking points back then was that one offset
> insistet in 32-bit offset/len and the other on 16-bit.

This version sizes the fields according to page size, was there
somewhere which wanted to use an offset > PAGE_SIZE (or size > PAGE_SIZE
for that matter). That would be pretty odd and/or not really a candidate
for using this datastructure?

Ian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
