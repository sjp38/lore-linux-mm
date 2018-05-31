Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0686B0008
	for <linux-mm@kvack.org>; Thu, 31 May 2018 12:05:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 54-v6so17421951wrw.1
        for <linux-mm@kvack.org>; Thu, 31 May 2018 09:05:53 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d12-v6si32385532wre.172.2018.05.31.09.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 09:05:52 -0700 (PDT)
Date: Thu, 31 May 2018 18:12:22 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 06/18] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180531161222.GC30465@lst.de>
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
> What if the file is reflinked and the current page covers a non-shared
> block but has an overlapping cow mapping due to cowextsize? The current
> logic unconditionally uses the COW mapping for writeback. The updated
> logic doesn't appear to do that in all cases. Consider if the current
> imap was delalloc (and so not trimmed) or the cow mapping was introduced
> after the current imap was mapped. This logic appears to prioritize the
> current mapping so long as it is valid. Doesn't that break the
> cowextsize hint?

It does.  I've fixed it for the next version.
