Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 466BA6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:04:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so44193604pge.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:04:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t12si847101plm.964.2017.08.11.11.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 11:04:48 -0700 (PDT)
Date: Fri, 11 Aug 2017 11:04:47 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170811180447.GA23669@infradead.org>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
 <20170811042519.GS21024@dastard>
 <20170811170847.GK31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811170847.GK31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 11, 2017 at 10:08:47AM -0700, Matthew Wilcox wrote:
> Assuming there's something fun we can do with filesystems that's
> interesting to this type of user, what do you think to this:
> 
> Create a block device (maybe it's a loop device, maybe it's dm-raid0)
> which supports DAX and uses the page cache to cache the physical pages
> of the block device it's fronting.

Why not make every block device just support fake DAX and avoid the
additional layer?

Basically this would be going back to a file cache indexed by
physical blocks from our logically indexed page cache model.  And
for a fs using heavy reflinks that's probably the right model in the
end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
