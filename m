Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 993186B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 04:15:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f23-v6so13475441wra.20
        for <linux-mm@kvack.org>; Tue, 22 May 2018 01:15:23 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j124-v6si11288908wmd.185.2018.05.22.01.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 01:15:22 -0700 (PDT)
Date: Tue, 22 May 2018 10:20:36 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
	buffer heads
Message-ID: <20180522082036.GA9801@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180518164830.1552-17-hch@lst.de> <20180521232700.GB14384@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521232700.GB14384@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, May 21, 2018 at 04:27:00PM -0700, Darrick J. Wong wrote:
> Something doesn't smell right here.  The only pages we need to read in
> are the first and last pages in the write_begin range, and only if they
> aren't page aligned and the underlying extent is IOMAP_MAPPED, right?

Yes,  and I'm pretty sure I did get this right before refactoring
everything for sub-blocksize support.
