Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2851D6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 02:58:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b83-v6so14098849wme.7
        for <linux-mm@kvack.org>; Wed, 30 May 2018 23:58:01 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d16-v6si3134092wrp.194.2018.05.30.23.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 23:58:00 -0700 (PDT)
Date: Thu, 31 May 2018 09:04:26 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 17/18] xfs: do not set the page uptodate in
	xfs_writepage_map
Message-ID: <20180531070426.GB32051@lst.de>
References: <20180530100013.31358-1-hch@lst.de> <20180530100013.31358-18-hch@lst.de> <20180530180839.GU837@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530180839.GU837@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:08:39AM -0700, Darrick J. Wong wrote:
> > and isn't present in other writepage implementations.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Looks ok, assuming that reads or buffered writes set the page
> uptodate...

Reads have to by definition, as do buffered writes that bring in
data / overwrite data.
