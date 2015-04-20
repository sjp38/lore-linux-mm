Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A28D6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 14:01:24 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so56528304qgd.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:01:24 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id w73si9800641qha.22.2015.04.20.11.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 11:01:24 -0700 (PDT)
Received: by qcpm10 with SMTP id m10so62873048qcp.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:01:23 -0700 (PDT)
Date: Mon, 20 Apr 2015 14:01:20 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 13/49] writeback: move bandwidth related fields from
 backing_dev_info into bdi_writeback
Message-ID: <20150420180120.GC4206@htj.duckdns.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-14-git-send-email-tj@kernel.org>
 <20150420150950.GB17020@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420150950.GB17020@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Jaegeuk Kim <jaegeuk@kernel.org>, Steven Whitehouse <swhiteho@redhat.com>

On Mon, Apr 20, 2015 at 05:09:50PM +0200, Jan Kara wrote:
> On Mon 06-04-15 15:58:02, Tejun Heo wrote:
> > Currently, a bdi (backing_dev_info) embeds single wb (bdi_writeback)
> > and the role of the separation is unclear.  For cgroup support for
> > writeback IOs, a bdi will be updated to host multiple wb's where each
> > wb serves writeback IOs of a different cgroup on the bdi.  To achieve
> > that, a wb should carry all states necessary for servicing writeback
> > IOs for a cgroup independently.
> > 
> > This patch moves bandwidth related fields from backing_dev_info into
> > bdi_writeback.
> > 
> > * The moved fields are: bw_time_stamp, dirtied_stamp, written_stamp,
> >   write_bandwidth, avg_write_bandwidth, dirty_ratelimit,
> >   balanced_dirty_ratelimit, completions and dirty_exceeded.
> > 
> > * writeback_chunk_size() and over_bgroup_thresh() now take @wb instead
> >   of @bdi.
>  				^^^ over_bground_thresh()
> 
> Otherwise the patch looks good to me. You can add:

Updated accordingly.

> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
