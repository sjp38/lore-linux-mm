Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 652046B02D0
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 18:56:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e12so22757pga.5
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 15:56:11 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a14si14365641pgd.623.2018.01.02.15.56.07
        for <linux-mm@kvack.org>;
        Tue, 02 Jan 2018 15:56:08 -0800 (PST)
Date: Wed, 3 Jan 2018 08:56:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm for mmotm: Revert skip swap cache feture for
 synchronous device
Message-ID: <20180102235606.GA19438@bbox>
References: <1514508907-10039-1-git-send-email-minchan@kernel.org>
 <20180102132214.289b725cf00ac07d91e8f60b@linux-foundation.org>
 <1514932941.4018.12.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1514932941.4018.12.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, Jens Axboe <axboe@kernel.dk>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Huang Ying <ying.huang@intel.com>

On Tue, Jan 02, 2018 at 02:42:21PM -0800, James Bottomley wrote:
> On Tue, 2018-01-02 at 13:22 -0800, Andrew Morton wrote:
> > On Fri, 29 Dec 2017 09:55:07 +0900 Minchan Kim <minchan@kernel.org>
> > wrote:
> > 
> > > 
> > > James reported a bug of swap paging-in for his testing and found it
> > > at rc5, soon to be -rc5.
> > > 
> > > Although we can fix the specific problem at the moment, it may
> > > have other lurkig bugs so want to have one more cycle in -next
> > > before merging.
> > > 
> > > This patchset reverts 23c47d2ada9f, 08fa93021d80, 8e31f339295f
> > > completely
> > > but 79b5f08fa34e partially because the swp_swap_info function that
> > > 79b5f08fa34e introduced is used by [1].
> > 
> > Gets a significant reject in do_swap_page().  Could you please take a
> > look, redo against current mainline?
> > 
> > Or not.  We had a bug and James fixed it.  That's what -rc is
> > for.  Why not fix the thing and proceed?
> 
> My main worry was lack of testing at -rc5, since the bug could
> essentially be excited by pushing pages out to swap and then trying to
> access them again ... plus since one serious bug was discovered it
> wouldn't be unusual for there to be others.  However, because of the
> IPT stuff, I think Linus is going to take 4.15 over a couple of extra
> -rc releases, so this is less of a problem.

Then, Here is right fix patch against current mainline.
