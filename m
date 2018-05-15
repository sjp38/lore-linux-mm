Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8C16B000C
	for <linux-mm@kvack.org>; Tue, 15 May 2018 03:22:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w74-v6so4659547wmw.0
        for <linux-mm@kvack.org>; Tue, 15 May 2018 00:22:09 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i12-v6si10015198wrb.223.2018.05.15.00.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 00:22:08 -0700 (PDT)
Date: Tue, 15 May 2018 09:26:25 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 31/33] iomap: add support for sub-pagesize buffered I/O
	without buffer heads
Message-ID: <20180515072625.GA23384@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-32-hch@lst.de> <eebcc4bf-f646-edc6-264b-124b3880f3cb@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eebcc4bf-f646-edc6-264b-124b3880f3cb@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, May 14, 2018 at 11:00:08AM -0500, Goldwyn Rodrigues wrote:
> > +	if (iop || i_blocksize(inode) == PAGE_SIZE)
> > +		return iop;
> 
> Why is this an equal comparison operator? Shouldn't this be >= to
> include filesystem blocksize greater than PAGE_SIZE?

Which filesystems would that be that have a tested and working PAGE_SIZE
support using iomap?
