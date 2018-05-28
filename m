Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 479266B0006
	for <linux-mm@kvack.org>; Mon, 28 May 2018 03:09:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y82-v6so8264739wmb.5
        for <linux-mm@kvack.org>; Mon, 28 May 2018 00:09:42 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p137-v6si5432925wme.25.2018.05.28.00.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 00:09:41 -0700 (PDT)
Date: Mon, 28 May 2018 09:15:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180528071543.GA5428@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-23-hch@lst.de> <20180524145935.GA84959@bfoster.bfoster> <20180524165350.GA22675@lst.de> <20180524181356.GA89391@bfoster.bfoster> <20180525061900.GA16409@lst.de> <20180525113532.GA92036@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525113532.GA92036@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Fri, May 25, 2018 at 07:35:33AM -0400, Brian Foster wrote:
> That comment is what I'm basing on...
> 
> > 	/*
> > 	 * We can end up here with no error and nothing to write if we
> > 	 * race with a partial page truncate on a sub-page block sized
> > 	 * filesystem. In that case we need to mark the page clean.
> > 	 */
> > 
> 
> So we can correctly end up with nothing to write on a dirty page, but it
> presumes a race with truncate. So suppose we end up with a dirty page,
>
> at least one uptodate block, count is zero (i.e., due to holes) and
> i_size is beyond the page. Would that not be completely bogus? If bogus,
> I think that would at least detect the dumb example I posted earlier.

The trivial file_offset >= i_size_read assert explodes pretty soon
in generic/091, and already does so with the existing mainline code.

I'd rather not open another can of worms right now..
