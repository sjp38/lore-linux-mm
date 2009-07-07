Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 161406B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:46:40 -0400 (EDT)
Date: Tue, 7 Jul 2009 17:48:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090707154809.GH2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144823.GE2714@wotan.suse.de> <20090707145820.GA9976@infradead.org> <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707150758.GA18075@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 11:07:58AM -0400, Christoph Hellwig wrote:
> On Tue, Jul 07, 2009 at 05:02:57PM +0200, Nick Piggin wrote:
> > That's kind of why I liked it in inode_setattr better.
> > 
> > But if the filesystem defines its own ->setattr, then it could simply
> > not define a ->setsize and do the right thing in setattr. So this
> > calling convention seems not too bad.
> 
> Or the filesystem could just call into it's own setattr method
> internally.  For that we'd switch back to passing the iattr to
> ->setsize.  For a filesystem that doesn't do anything special for
> ATTR_SIZE ->setsize could point to the same function as ->setattr.
> 
> For filesystem where's it's really different they could be separate or
> share helpers.

OK, so what do you suggest? If the filesystem defines
->setsize then do not pass ATTR_SIZE changes into setattr?
But then do you also not pass in ATTR_TIME cchanges to setattr
iff they  are together with ATTR_SIZE change? It sees also like
quite a difficult calling convention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
