Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E9B986B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 11:56:01 -0400 (EDT)
Date: Mon, 10 Oct 2011 11:55:57 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/9] mm: add a "struct subpage" type containing a page,
 offset and length
Message-ID: <20111010155557.GA15503@infradead.org>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
 <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 10, 2011 at 12:11:33PM +0100, Ian Campbell wrote:
> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 
> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.

Subpage seems like a fairly bad name.  page_frag would fit into the
scheme used in a few other places.

The brings back the discussion of unifying the various incarnations we
have of this (biovec, skb frag and there were a few more at times),
but IIRC one of the sticking points back then was that one offset
insistet in 32-bit offset/len and the other on 16-bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
