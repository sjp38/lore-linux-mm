Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A489D6B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 05:04:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l6-v6so10782801wrn.17
        for <linux-mm@kvack.org>; Mon, 21 May 2018 02:04:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k64-v6si4150781edc.17.2018.05.21.02.04.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 May 2018 02:04:13 -0700 (PDT)
Date: Mon, 21 May 2018 11:04:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
 CONFIG_DEV_PAGEMAP_OPS
Message-ID: <20180521090410.7ygosxzjfhceqrq4@quack2.suse.cz>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180518094616.GA25838@lst.de>
 <CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri 18-05-18 09:00:29, Dan Williams wrote:
> On Fri, May 18, 2018 at 2:46 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> +     select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
> >
> > Btw, what was the reason again we couldn't get rid of FS_DAX_LIMITED?
> 
> The last I heard from Gerald they were still mildly interested in
> keeping the dccssblk dax support going with this limited mode, and
> threatened to add full page support at a later date:
> 
> ---
> From: Gerald
> 
> dcssblk seems to work fine, I did not see any SIGBUS while "executing
> in place" from dcssblk with the current upstream kernel, maybe because
> we only use dcssblk with fs dax in read-only mode.
> 
> Anyway, the dcssblk change is fine with me. I will look into adding
> struct pages for dcssblk memory later, to make it work again with
> this change, but for now I do not know of anyone needing this in the
> upstream kernel.
> 
> https://www.spinics.net/lists/linux-xfs/msg14628.html
> ---

We definitely do have customers using "execute in place" on s390x from
dcssblk. I've got about two bug reports for it when customers were updating
from old kernels using original XIP to kernels using DAX. So we need to
keep that working.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
