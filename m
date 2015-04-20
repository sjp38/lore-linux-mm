Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id B2F4F6B0038
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 14:21:57 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so63230885qcb.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:21:57 -0700 (PDT)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id dh6si20368584qcb.15.2015.04.20.11.21.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 11:21:56 -0700 (PDT)
Received: by qkhg7 with SMTP id g7so195605657qkh.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:21:56 -0700 (PDT)
Date: Mon, 20 Apr 2015 14:21:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 18/49] bdi: make inode_to_bdi() inline
Message-ID: <20150420182153.GE4206@htj.duckdns.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-19-git-send-email-tj@kernel.org>
 <20150420154050.GH17020@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420154050.GH17020@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon, Apr 20, 2015 at 05:40:50PM +0200, Jan Kara wrote:
> > This patch makes inode_to_bdi() and sb_is_blkdev_sb() that the
> > function calls inline.  blockdev_superblock and noop_backing_dev_info
> > are EXPORT_GPL'd to allow the inline functions to be used from
> > modules.
>   I somewhat hate making blockdev_superblock exported just for this. But
> OK.

Hopefully people won't get creative with it.

> > While at it, maske sb_is_blkdev_sb() return bool instead of int.
>                ^^^ make

Updated.

>   Otherwise the patch looks good. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
