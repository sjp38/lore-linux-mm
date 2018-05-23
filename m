Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC00C6B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 01:58:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18-v6so4444465wrm.6
        for <linux-mm@kvack.org>; Tue, 22 May 2018 22:58:19 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p23-v6si942635wmh.109.2018.05.22.22.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 22:58:18 -0700 (PDT)
Date: Wed, 23 May 2018 08:03:40 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
	buffer heads
Message-ID: <20180523060340.GA13873@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180518164830.1552-17-hch@lst.de> <20180521232700.GB14384@magnolia> <20180522000745.GU23861@dastard> <20180522082454.GB9801@lst.de> <20180522223806.GX23861@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522223806.GX23861@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 08:38:06AM +1000, Dave Chinner wrote:
> Ok, I missed that detail as it's in a different patch. It looks like
> if (pos > EOF) it will zeroed. But in this case I think that pos ==
> EOF and so it was reading instead. That smells like off-by-one bug
> to me.

This has been fixed in the tree I pushed yesterday already.
