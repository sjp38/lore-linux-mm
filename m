Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6066F6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 12:04:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v12-v6so14322823wmc.1
        for <linux-mm@kvack.org>; Thu, 31 May 2018 09:04:43 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n132-v6si1136240wmb.206.2018.05.31.09.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 09:04:33 -0700 (PDT)
Date: Thu, 31 May 2018 18:11:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 06/18] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180531161103.GA30465@lst.de>
References: <20180530100013.31358-1-hch@lst.de> <20180530100013.31358-7-hch@lst.de> <20180530173955.GF112411@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530173955.GF112411@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Wed, May 30, 2018 at 01:39:56PM -0400, Brian Foster wrote:
> I believe Dave originally intended to split this up into multiple
> patches. Dave, did you happen to get anywhere with that before Christoph
> pulled this in?

I've split a few bits off.

> 
> If not, could we at least split off some of the behavior changes into
> separate patches? For example, dropping the !mapped && uptodate check
> that causes us to writeback zeroed blocks over unwritten extents is a
> behavior change that warrants a separate patch.

But that is the one part I can't easily split off.  It would require
tons of spurious changes to the old system of buffer flags, which
might be doable but would be removed in the next patch.
