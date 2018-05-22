Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD7A6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 03:51:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n17-v6so8901369wmc.8
        for <linux-mm@kvack.org>; Tue, 22 May 2018 00:51:01 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i18-v6si11757706wmh.82.2018.05.22.00.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 00:51:00 -0700 (PDT)
Date: Tue, 22 May 2018 09:56:14 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 05/34] fs: use ->is_partially_uptodate in
	page_cache_seek_hole_data
Message-ID: <20180522075614.GA9430@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180518164830.1552-6-hch@lst.de> <20180521195304.GA14384@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521195304.GA14384@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index bef5e91d40bf..0fecd5789d7b 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -594,31 +594,54 @@ EXPORT_SYMBOL_GPL(iomap_fiemap);
> >   *
> >   * Returns the offset within the file on success, and -ENOENT otherwise.
> 
> This comment is now wrong, since we return the offset via *lastoff and I
> think the return value is whether or not we found what we were looking
> for...?

Yes.  I'll just drop the comment as it doesn't add much value to start
with.

> > +	if (bsize == PAGE_SIZE || !ops->is_partially_uptodate) {
> > +		if (PageUptodate(page) == seek_data)
> > +			return true;
> > +		return false;
> 
> return PageUptodate(page) == seek_data; ?

Sure, I'll uptodate the patch.
