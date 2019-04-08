Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56E44C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 13:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC25D213F2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 13:44:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC25D213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E8566B0005; Mon,  8 Apr 2019 09:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E136B0006; Mon,  8 Apr 2019 09:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 337DB6B0007; Mon,  8 Apr 2019 09:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2BC26B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 09:44:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so6982259eda.10
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 06:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pWZJtlfK4etIVwvIIZwguUHO5kvBJnPmfv7001TVuW4=;
        b=QaZcIe7PHajG1dCAdsopV3EVKKGWiBSn8Neq26jO8mpk7XB4KtDGN7ggG1k/GdnRJb
         1ziRRjml68NYEDd3/rK3rETgUtBx5pnKJzAvqXL3/wR0ESEWf64cDiS/wrcwESaGhw5F
         dXF77K7hscL8KTeIbZzPvzbucorhfgndvxNE0TVG+t1AVBM6/K1a5AIY5n7Z4IgppGJ1
         h/HUUNJFP5S0S5Ubh/IphZ+GKkHUk09VtajegEByDz552y0qMh/z3G/QNh6TsH51uy1d
         25vkZSVFkPVzudZPJVN8JsroI8H6wFr8/cZ2VimRs19D3m20nl/xsnZAtdcVFH8ydXOo
         YKXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWSH2SYummU2j4zYfTKPGGQ4VjN1dRs5zDNUW1/7ce2ZIKT4Y97
	8n6hzAVbtyLVBBRhVbEQYg6pm1iINH2uD4BpQzsC0oQTF6Q6c516YCIEoRiUaM0Mn5d88pTIWPj
	w7UL+NH7ebqgSeWgbPdHU1Db2Y/V5bUx3IZFGWQm/CyFasnj9eZVtgndoL5PDo3F5hA==
X-Received: by 2002:a17:906:4c4e:: with SMTP id d14mr8242466ejw.127.1554731048287;
        Mon, 08 Apr 2019 06:44:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFwjh04YXvpiKLfdR4qnoghTAdwKSRUHLU8YYadkd2HS9lRtkGGGthAOPM9UjQ/1bRAXsI
X-Received: by 2002:a17:906:4c4e:: with SMTP id d14mr8242399ejw.127.1554731047186;
        Mon, 08 Apr 2019 06:44:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554731047; cv=none;
        d=google.com; s=arc-20160816;
        b=PHUMab0B8jWqB42Pgh9cpRPLcu3SNKZb4nXi0IQhiXm1pEHjq5y7PRMNx9wl9Yt2Nl
         +x0nN24gstCH0JzDox8rTe1LfXUQY4LGsDMDkh/G1Lmupt+xMFF/4JTF5hnPSGfEBkj/
         qusBtPptxhaqJdqArsec9g2qA9WKOOMu+lKYBzI46IB9nLC6cI8/Y9FrqzUFCGgoYm1c
         j6sWpmb9rq76+/dAl+aMaNZzyQJGFdsPA0ra78Z49P2puKe0ie2X27Ua0tA/TLRzFiZw
         ULd3eIIQ8VHRk6h9+IeDE9BX9bSarwoYsmVoXQcYGslAccKfGWjGvCmsVqh5UhKHn4uw
         CQEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pWZJtlfK4etIVwvIIZwguUHO5kvBJnPmfv7001TVuW4=;
        b=O2XjYB9KXkl/hFF0gpXaVbnX6AH5oLDdJvvcvk35SoIJwR/o/eW/BpGMjqLBcbl7vF
         1xRiA0i/KqNM1HNSwKhJtCKGJ1GL/F7bDGpqQqHfx/Xa0tc04o7MJaua8gxZw+VaQeY2
         Cvw6hZpQ6EH2c0Ykqn9+Ek8reuIzOkaafCnJwvqPZ3NC9TReB/L81Lmjzhbjk5c6rCJw
         zZ+2+QsDVwQrmBXXN+pk4l/goVmXBXyN7Usxw1jtjvzPBRiLNomdqnF2XDwdB4bOGiWZ
         QCHjogMPw9xE/KiF+O7yPm1z21G6dHHKzuTNOk4Sleu1MgeTmJC1j0gzskXlw8XS7TCq
         Nc3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w40si430137edd.257.2019.04.08.06.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 06:44:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 85307AA71;
	Mon,  8 Apr 2019 13:44:06 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id D998F1E424A; Mon,  8 Apr 2019 15:44:05 +0200 (CEST)
Date: Mon, 8 Apr 2019 15:44:05 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>,
	cluster-devel <cluster-devel@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Subject: Re: gfs2 iomap dealock, IOMAP_F_UNBALANCED
Message-ID: <20190408134405.GA15023@quack2.suse.cz>
References: <20190321131304.21618-1-agruenba@redhat.com>
 <20190328165104.GA21552@lst.de>
 <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com>
 <20190407073213.GA9509@lst.de>
 <CAHc6FU7kgm4OyrY-KRb8H2w6LDrWDSJ2p=UgZeeJ8YrHynKU2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHc6FU7kgm4OyrY-KRb8H2w6LDrWDSJ2p=UgZeeJ8YrHynKU2w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 08-04-19 10:53:34, Andreas Gruenbacher wrote:
> On Sun, 7 Apr 2019 at 09:32, Christoph Hellwig <hch@lst.de> wrote:
> >
> > [adding Jan and linux-mm]
> >
> > On Fri, Mar 29, 2019 at 11:13:00PM +0100, Andreas Gruenbacher wrote:
> > > > But what is the requirement to do this in writeback context?  Can't
> > > > we move it out into another context instead?
> > >
> > > Indeed, this isn't for data integrity in this case but because the
> > > dirty limit is exceeded. What other context would you suggest to move
> > > this to?
> > >
> > > (The iomap flag I've proposed would save us from getting into this
> > > situation in the first place.)
> >
> > Your patch does two things:
> >
> >  - it only calls balance_dirty_pages_ratelimited once per write
> >    operation instead of once per page.  In the past btrfs did
> >    hacks like that, but IIRC they caused VM balancing issues.
> >    That is why everyone now calls balance_dirty_pages_ratelimited
> >    one per page.  If calling it at a coarse granularity would
> >    be fine we should do it everywhere instead of just in gfs2
> >    in journaled mode
> >  - it artifically reduces the size of writes to a low value,
> >    which I suspect is going to break real life application
> 
> Not quite, balance_dirty_pages_ratelimited is called from iomap_end,
> so once per iomap mapping returned, not per write. (The first version
> of this patch got that wrong by accident, but not the second.)
> 
> We can limit the size of the mappings returned just in that case. I'm
> aware that there is a risk of balancing problems, I just don't have
> any better ideas.
> 
> This is a problem all filesystems with data-journaling will have with
> iomap, it's not that gfs2 is doing anything particularly stupid.

I agree that if ext4 would be using iomap, it would have similar issues.

> > So I really think we need to fix this properly.  And if that means
> > that you can't make use of the iomap batching for gfs2 in journaled
> > mode that is still a better option.
> 
> That would mean using the old-style, page-size allocations, and a
> completely separate write path in that case. That would be quite a
> nightmare.
> 
> > But I really think you need
> > to look into the scope of your flush_log and figure out a good way
> > to reduce that as solve the root cause.
> 
> We won't be able to do a log flush while another transaction is
> active, but that's what's needed to clean dirty pages. iomap doesn't
> allow us to put the block allocation into a separate transaction from
> the page writes; for that, the opposite to the page_done hook would
> probably be needed.

I agree that a ->page_prepare() hook would be probably the cleanest
solution for this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

