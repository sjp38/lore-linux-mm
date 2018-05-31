Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 916646B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 02:56:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so15972986wre.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 23:56:42 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t19-v6si24488047wrg.75.2018.05.30.23.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 23:56:41 -0700 (PDT)
Date: Thu, 31 May 2018 09:03:07 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 13/18] xfs: don't look at buffer heads in
	xfs_add_to_ioend
Message-ID: <20180531070307.GA32051@lst.de>
References: <20180530100013.31358-1-hch@lst.de> <20180530100013.31358-14-hch@lst.de> <20180530175529.GQ837@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530175529.GQ837@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 10:55:29AM -0700, Darrick J. Wong wrote:
> > +	sector = xfs_fsb_to_db(ip, wpc->imap.br_startblock) +
> > +		((offset - XFS_FSB_TO_B(mp, wpc->imap.br_startoff)) >> 9);
> 
> " >> SECTOR_SHIFT" here?  If so, I can fix this on its way in.

The >> 9 that until very recently was used everywhere makes it nicely
fit on two lines.  But the fixup is ok with me, too.
