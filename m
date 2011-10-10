Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFA876B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:19:45 -0400 (EDT)
Date: Mon, 10 Oct 2011 12:19:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/9] mm: add a "struct subpage" type containing a page,
 offset and length
Message-ID: <20111010161942.GA751@infradead.org>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
 <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
 <20111010155557.GA15503@infradead.org>
 <1318263059.21903.462.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318263059.21903.462.camel@zakaz.uk.xensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Christoph Hellwig <hch@infradead.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Oct 10, 2011 at 05:10:59PM +0100, Ian Campbell wrote:
> This version sizes the fields according to page size, was there
> somewhere which wanted to use an offset > PAGE_SIZE (or size > PAGE_SIZE
> for that matter). That would be pretty odd and/or not really a candidate
> for using this datastructure?

I wasn't ever part of the fight myself and only vaguely remember it.
Try to get linux-kernel and Jens onto the Cc list to at least have the
major stakeholders informed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
