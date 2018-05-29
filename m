Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8D7F6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:26:34 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id y49-v6so9423277oti.11
        for <linux-mm@kvack.org>; Tue, 29 May 2018 04:26:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5-v6si12768465otb.442.2018.05.29.04.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 04:26:33 -0700 (PDT)
Date: Tue, 29 May 2018 07:26:31 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180529112630.GA107328@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-23-hch@lst.de>
 <20180524145935.GA84959@bfoster.bfoster>
 <20180524165350.GA22675@lst.de>
 <20180524181356.GA89391@bfoster.bfoster>
 <20180525061900.GA16409@lst.de>
 <20180525113532.GA92036@bfoster.bfoster>
 <20180528071543.GA5428@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180528071543.GA5428@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Mon, May 28, 2018 at 09:15:43AM +0200, Christoph Hellwig wrote:
> On Fri, May 25, 2018 at 07:35:33AM -0400, Brian Foster wrote:
> > That comment is what I'm basing on...
> > 
> > > 	/*
> > > 	 * We can end up here with no error and nothing to write if we
> > > 	 * race with a partial page truncate on a sub-page block sized
> > > 	 * filesystem. In that case we need to mark the page clean.
> > > 	 */
> > > 
> > 
> > So we can correctly end up with nothing to write on a dirty page, but it
> > presumes a race with truncate. So suppose we end up with a dirty page,
> >
> > at least one uptodate block, count is zero (i.e., due to holes) and
> > i_size is beyond the page. Would that not be completely bogus? If bogus,
> > I think that would at least detect the dumb example I posted earlier.
> 
> The trivial file_offset >= i_size_read assert explodes pretty soon
> in generic/091, and already does so with the existing mainline code.
> 

What exactly is the trivial check? Can you show the code please?

Brian

> I'd rather not open another can of worms right now..
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
