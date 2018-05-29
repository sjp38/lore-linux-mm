Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C51CA6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 09:02:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l6-v6so12613830wrn.17
        for <linux-mm@kvack.org>; Tue, 29 May 2018 06:02:35 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 34-v6si27904930wre.368.2018.05.29.06.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 06:02:34 -0700 (PDT)
Date: Tue, 29 May 2018 15:08:46 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180529130846.GA8205@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-23-hch@lst.de> <20180524145935.GA84959@bfoster.bfoster> <20180524165350.GA22675@lst.de> <20180524181356.GA89391@bfoster.bfoster> <20180525061900.GA16409@lst.de> <20180525113532.GA92036@bfoster.bfoster> <20180528071543.GA5428@lst.de> <20180529112630.GA107328@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529112630.GA107328@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 29, 2018 at 07:26:31AM -0400, Brian Foster wrote:
> What exactly is the trivial check? Can you show the code please?

ASSERT(file_offset > i_size_read(inode)) in the !count block
at the end of xfs_writepage_map.

(file_offset replaced with page_offset(page) + offset for the mainline
code).
