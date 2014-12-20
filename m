Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAA06B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 01:01:37 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so2923221wgh.37
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 22:01:36 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id g10si7190155wix.1.2014.12.19.22.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 22:01:36 -0800 (PST)
Date: Sat, 20 Dec 2014 06:01:30 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 2/5] direct-io: don't dirty ITER_BVEC pages on read
Message-ID: <20141220060130.GA22149@ZenIV.linux.org.uk>
References: <cover.1419044605.git.osandov@osandov.com>
 <f9b69250ba0598807d96857e9b736d57e6841ba3.1419044605.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9b69250ba0598807d96857e9b736d57e6841ba3.1419044605.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>

On Fri, Dec 19, 2014 at 07:18:26PM -0800, Omar Sandoval wrote:
> Reads through the iov_iter infrastructure for kernel pages shouldn't be
> dirtied by the direct I/O code.
> 
> This is based on Dave Kleikamp's and Ming Lei's previously posted
> patches.

Umm...  

> +	dio->should_dirty = !iov_iter_is_bvec(iter);

	dio->should_dirty = iter_is_iovec(iter);

perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
