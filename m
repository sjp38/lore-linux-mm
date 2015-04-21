Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA85900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 11:06:06 -0400 (EDT)
Received: by lagv1 with SMTP id v1so153464045lag.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 08:06:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si4122433wif.84.2015.04.21.08.06.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 08:06:04 -0700 (PDT)
Date: Tue, 21 Apr 2015 17:05:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 12/49] writeback: move backing_dev_info->bdi_stat[] into
 bdi_writeback
Message-ID: <20150421150559.GB32616@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-13-git-send-email-tj@kernel.org>
 <20150420150231.GA17020@quack.suse.cz>
 <20150420175626.GB4206@htj.duckdns.org>
 <20150421085119.GA24278@quack.suse.cz>
 <20150421150229.GA9455@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150421150229.GA9455@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@primarydata.com>

On Tue 21-04-15 11:02:29, Tejun Heo wrote:
> On Tue, Apr 21, 2015 at 10:51:19AM +0200, Jan Kara wrote:
> >   I can easily understand what "initializing writeback structure" means but
> > "exiting writeback structure" doesn't really make sense to me. OTOH
> > "destroying writeback structure" does make sense to me. That's the only
> > reason.
> 
> We have enough cases where "exit" is used that way starting with
> module_exit() and all the accompanying __exit annotations and there
> are quite a few others.  I think it's enough to establish "exit" as
> the counterpart of "init" but I do agree that it felt a bit alien to
> me at the beginning too.
> 
> In general, I've been sticking with create/destroy if the object
> itself is being created or destroyed and init/exit if the object
> itself stays put across init/exit which is the case here.  This isn't
> quite universal but I think there exists enough of a pattern to make
> it worthwhile to stick to it.  As such, I'd like to stick to the
> current names if it isn't a big deal.
  It's not a big deal, so feel free to keep your naming. It's not a
function I'd stare at every day ;)

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
