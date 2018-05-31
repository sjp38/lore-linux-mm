Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3486B0006
	for <linux-mm@kvack.org>; Thu, 31 May 2018 12:05:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b83-v6so14809322wme.7
        for <linux-mm@kvack.org>; Thu, 31 May 2018 09:05:10 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h201-v6si1144047wme.228.2018.05.31.09.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 09:05:08 -0700 (PDT)
Date: Thu, 31 May 2018 18:11:38 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 07/18] xfs: remove the now unused XFS_BMAPI_IGSTATE flag
Message-ID: <20180531161138.GB30465@lst.de>
References: <20180530100013.31358-1-hch@lst.de> <20180530100013.31358-8-hch@lst.de> <20180531134637.GA2997@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531134637.GA2997@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 31, 2018 at 09:46:38AM -0400, Brian Foster wrote:
> On Wed, May 30, 2018 at 12:00:02PM +0200, Christoph Hellwig wrote:
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> 
> The change looks Ok... It's clearly reasonable to remove a flag that is
> no longer used, but why is it no longer used? The previous patch drops
> it to "make xfs_writepage_map() extent map centric," but the description
> doesn't exactly explain why (and it's not immediately clear to me
> amongst all the other code changes).

My refactoring moves this into a separate patch with a proper changelog,
I'll send it out in a bit.
