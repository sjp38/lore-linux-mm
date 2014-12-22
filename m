Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4DB6B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 02:12:22 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so5375895pac.11
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:12:22 -0800 (PST)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id bg5si24054189pbc.38.2014.12.21.23.12.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Dec 2014 23:12:21 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id r10so5276862pdi.23
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:12:20 -0800 (PST)
Date: Sun, 21 Dec 2014 23:12:16 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 2/5] direct-io: don't dirty ITER_BVEC pages on read
Message-ID: <20141222071216.GA24722@mew>
References: <cover.1419044605.git.osandov@osandov.com>
 <f9b69250ba0598807d96857e9b736d57e6841ba3.1419044605.git.osandov@osandov.com>
 <20141220060130.GA22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220060130.GA22149@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>

On Sat, Dec 20, 2014 at 06:01:30AM +0000, Al Viro wrote:
> On Fri, Dec 19, 2014 at 07:18:26PM -0800, Omar Sandoval wrote:
> > Reads through the iov_iter infrastructure for kernel pages shouldn't be
> > dirtied by the direct I/O code.
> > 
> > This is based on Dave Kleikamp's and Ming Lei's previously posted
> > patches.
> 
> Umm...  
> 
> > +	dio->should_dirty = !iov_iter_is_bvec(iter);
> 
> 	dio->should_dirty = iter_is_iovec(iter);
> 
> perhaps?

Mm, yeah, I'll do that. That helper snuck in without me noticing it... I
see that we can't do iov_iter_get_pages on an ITER_KVEC, so a kvec
doesn't work for blockdev_direct_IO anyways, right?

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
