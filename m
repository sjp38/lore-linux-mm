Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01F8E6B02A0
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:03:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p7-v6so14769996wrj.4
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:03:44 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j131-v6si13897988wmg.197.2018.05.30.03.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 03:03:43 -0700 (PDT)
Date: Wed, 30 May 2018 12:10:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [Cluster-devel] [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to
	gfs2
Message-ID: <20180530101003.GA31419@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-12-hch@lst.de> <20180530055033.GZ30110@magnolia> <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com> <20180530095911.GB31068@lst.de> <e14b3cfb-73ca-e712-e1e9-4ceabc8c7b6d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e14b3cfb-73ca-e712-e1e9-4ceabc8c7b6d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com, linux-mm@kvack.org, Andreas =?iso-8859-1?Q?Gr=FCnbacher?= <agruenba@redhat.com>

On Wed, May 30, 2018 at 11:02:08AM +0100, Steven Whitehouse wrote:
> In that case,  maybe it would be simpler to drop it for GFS2. Unless we 
> are getting a lot of benefit from it, then we should probably just follow 
> the generic pattern here. Eventually we'll move everything to iomap, so 
> that the bh mapping interface will be gone. That implies that we might be 
> able to drop it now, to avoid this complication during the conversion.
>
> Andreas, do you see any issues with that?

I suspect it actually is doing the wrong thing today.  It certainly
does for SSDs, and it probably doesn't do a useful thing for modern
disks with intelligent caches either.
