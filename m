Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 907C6900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 04:51:30 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so58520747wic.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 01:51:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk2si1985969wjb.205.2015.04.21.01.51.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 01:51:28 -0700 (PDT)
Date: Tue, 21 Apr 2015 10:51:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 12/49] writeback: move backing_dev_info->bdi_stat[] into
 bdi_writeback
Message-ID: <20150421085119.GA24278@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-13-git-send-email-tj@kernel.org>
 <20150420150231.GA17020@quack.suse.cz>
 <20150420175626.GB4206@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420175626.GB4206@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@primarydata.com>

On Mon 20-04-15 13:56:26, Tejun Heo wrote:
> On Mon, Apr 20, 2015 at 05:02:31PM +0200, Jan Kara wrote:
> >   Maybe bdi_wb_destroy() would be somewhat more descriptive than
> > bdi_wb_exit()? Otherwise the patch looks good to me. You can add:
> > Reviewed-by: Jan Kara <jack@suse.cz>
> 
> Hmmm... maybe, I don't know.  I feel weird matching up destroy with
> init instead of create.  Why is exit weird?
  I can easily understand what "initializing writeback structure" means but
"exiting writeback structure" doesn't really make sense to me. OTOH
"destroying writeback structure" does make sense to me. That's the only
reason.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
