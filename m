Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ADB6C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465A220870
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:16:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465A220870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC9918E0002; Fri,  1 Feb 2019 00:16:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C77A88E0001; Fri,  1 Feb 2019 00:16:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3F798E0002; Fri,  1 Feb 2019 00:16:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71E268E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:16:17 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so4223999plr.8
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:16:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1xNzf00S/LzGkQOCjoDX4XDIJZBX+cOUOINvlfibkX8=;
        b=NX07SMspFiyLTj2B07HZSM0lrqSALk4cirePXOtCclI8tKcJqs8ik77DdNgalgkSE+
         WbXxX5mkGkNdTPmbnQ7YL9ML5P06K0TXsDBUixzlubNbxOFjUjk2w8ff/H49gZ/GX7g/
         LRk1byWWuWJuUHX5BT3w+6pXqkw2xzOVkr7j7lPmZiL7x4jQ8P4oivIBe1+RyFyFrZRL
         moHfXjCRCQtOC9YiQTwWzOktZCqrcrigrG5GM22u10zzgG6gahFgY5GFBQ6NUzqh/q+S
         KOT4GKBJHiMDf1MBP2RB/43qg2WVlK+KeoWc4RgfC7Rv0BI+tySmW0OxM049vmmRg12Z
         D4rQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukcPkBwDrWBOdSprvNWhWz3pF47goYXTxXaom9FXkUy0oIDhQZsT
	nhJgMScK30XztOxq0W7UA6UhnKH2XmjEAeFvQ5iQ119dXZX2GQ+RahPGtGV1HLw2YAhs4b//qzw
	k4KrSgSJALx2nLh5NxRXlNELYL3cOPlDsFpdJBNJVWbSt7sSOx5Gm2woucWuypuw=
X-Received: by 2002:a17:902:7481:: with SMTP id h1mr38486339pll.341.1548998177011;
        Thu, 31 Jan 2019 21:16:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN442r9Uc7+MNoDLjYyX8+VFCsLi9c/PKFgAi6k9TYCqHjOXw45lNtEgyHOOAt9LU1+cuvi1
X-Received: by 2002:a17:902:7481:: with SMTP id h1mr38486305pll.341.1548998176120;
        Thu, 31 Jan 2019 21:16:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998176; cv=none;
        d=google.com; s=arc-20160816;
        b=mQJDlEWJtKPzEYyEJjgFarRPNgTDy82Wi1YPswNej3rC9yGa5szy4ZVvxcNgHFk3gA
         hERjDbF6stV+EA05L5BD43wItT2h+IhyK8U9AVAOsW6MK1nGcllB1j3KT6/2nX2o1P32
         xT6LA1IQdma2Hin0E6v6zi/wLO5l6I6yqJgC+ES7GJ2KtClUJC67Hs964HpYOZwMa+8z
         ckvKc+UghBhVSKmRHc9iFkxamyIe2fbpaXSnVXd/LaTHAEIdZDMbzpDH1Hc9R1UccHOU
         vYxG5HNvWYv5LfWlMOXdR9m12FWJ+1iVk+pq5GDOeZhsPxwl3mQBFVlUoAyMaW5nqwqz
         6z/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1xNzf00S/LzGkQOCjoDX4XDIJZBX+cOUOINvlfibkX8=;
        b=SoYnfJKC6AZb2LiGQ1//jKSPKKPRrhQxgUsEitHG98aH2HVkV7XTt9TM1+knD5pgQH
         uUNu3fEny6XPuHCbbTGXhpyqkJdM0C6G45K7Run3BOzEPP/Pxq+rW7TJsmWf8iBgdTNY
         5KVzkc4DD7hu+fk4C/gp3Er6UVxXX6MG5QPXb6fHPnrC/Fj7kbw7Cx5/rZD+u9r4R3o/
         HwYhJr2E9ofgClNmHIQZB6oIx5MeYBi9GwDhMLeuBJn0i6K9SrmnyCOAkic6X9su1HEW
         BONkgSd1E/wQszt9lZhEg+rcp5gVtzQQvx9nCN7C1ShTgzH4jO7x2HkGGbAqHrP2iufj
         xjTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id 86si4420315pfl.46.2019.01.31.21.16.12
        for <linux-mm@kvack.org>;
        Thu, 31 Jan 2019 21:16:16 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.139;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.139 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl2.internode.on.net with ESMTP; 01 Feb 2019 15:43:56 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gpR9H-0003ex-Rm; Fri, 01 Feb 2019 16:13:55 +1100
Date: Fri, 1 Feb 2019 16:13:55 +1100
From: Dave Chinner <david@fromorbit.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Jiri Kosina <jikos@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
Message-ID: <20190201051355.GV6173@dastard>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz>
 <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:54:16AM -0800, Linus Torvalds wrote:
> On Thu, Jan 31, 2019 at 2:23 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > OK, I guess my question was not precise. What does prevent taking fs
> > locks down the path?
> 
> IOCB_NOWAIT has never meant that, and will never mean it.

I think you're wrong, Linus. IOCB_NOWAIT was specifically designed
to prevent blocking on filesystem locks during AIO submission. The
initial commits spell that out pretty clearly:

commit b745fafaf70c0a98a2e1e7ac8cb14542889ceb0e
Author: Goldwyn Rodrigues <rgoldwyn@suse.com>
Date:   Tue Jun 20 07:05:43 2017 -0500

    fs: Introduce RWF_NOWAIT and FMODE_AIO_NOWAIT
    
    RWF_NOWAIT informs kernel to bail out if an AIO request will block
    for reasons such as file allocations, or a writeback triggered,
    or would block while allocating requests while performing
    direct I/O.
    
    RWF_NOWAIT is translated to IOCB_NOWAIT for iocb->ki_flags.
    
    FMODE_AIO_NOWAIT is a flag which identifies the file opened is capable
    of returning -EAGAIN if the AIO call will block. This must be set by
    supporting filesystems in the ->open() call.
    
    Filesystems xfs, btrfs and ext4 would be supported in the following patches.
    
    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Reviewed-by: Jan Kara <jack@suse.cz>
    Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
    Signed-off-by: Jens Axboe <axboe@kernel.dk>

commit 29a5d29ec181ebdc98a26cedbd76ce9870248892
Author: Goldwyn Rodrigues <rgoldwyn@suse.com>
Date:   Tue Jun 20 07:05:48 2017 -0500

    xfs: nowait aio support
    
    If IOCB_NOWAIT is set, bail if the i_rwsem is not lockable
    immediately.
    
    IF IOMAP_NOWAIT is set, return EAGAIN in xfs_file_iomap_begin
    if it needs allocation either due to file extension, writing to a hole,
    or COW or waiting for other DIOs to finish.
    
    Return -EAGAIN if we don't have extent list in memory.
    
    Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
    Signed-off-by: Jens Axboe <axboe@kernel.dk>

commit 728fbc0e10b7f3ce2ee043b32e3453fd5201c055
Author: Goldwyn Rodrigues <rgoldwyn@suse.com>
Date:   Tue Jun 20 07:05:47 2017 -0500

    ext4: nowait aio support
    
    Return EAGAIN if any of the following checks fail for direct I/O:
      + i_rwsem is lockable
      + Writing beyond end of file (will trigger allocation)
      + Blocks are not allocated at the write location
    
    Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
    Reviewed-by: Jan Kara <jack@suse.cz>
    Signed-off-by: Jens Axboe <axboe@kernel.dk>

> We will never give user space those kinds of guarantees. We do locking
> for various reasons.  For example, we'll do the mm lock just when
> fetching/storing data from/to user space if there's a page fault.

You are conflating "best effort non-blocking operation" with
"atomic guarantee".  RWF_NOWAIT/IOCB_NOWAIT is the
former, not the latter.

i.e. RWF_NOWAIT addresses the "every second IO submission blocks"
problems that AIO submission suffered from due to filesystem lock
contention, not the rare and unusual things like  "page fault during
get_user_pages in direct IO submission".  Maybe one day, but right
now those rare cases are not pain points for applications that
require nonblock AIO submission via RWF_NOWAIT.

> Or -
> more obviously - we'll also check for - and sleep on - mandatory locks
> in rw_verify_area().

Well, only if you don't use fcntl(O_NONBLOCK) on the file to tell
mandatory locking to fail with -EAGAIN instead of sleeping.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

