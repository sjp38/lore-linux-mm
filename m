Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id A95CF9003CE
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 23:08:31 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so43618353qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:08:31 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id i65si4829366qkh.58.2015.07.01.20.08.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 20:08:31 -0700 (PDT)
Received: by qkhu186 with SMTP id u186so43618251qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:08:30 -0700 (PDT)
Date: Wed, 1 Jul 2015 23:08:28 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 51/51] ext2: enable cgroup writeback support
Message-ID: <20150702030828.GO26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-52-git-send-email-tj@kernel.org>
 <20150701192912.GN7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701192912.GN7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, linux-ext4@vger.kernel.org

On Wed, Jul 01, 2015 at 09:29:12PM +0200, Jan Kara wrote:
> On Fri 22-05-15 17:14:05, Tejun Heo wrote:
> > Writeback now supports cgroup writeback and the generic writeback,
> > buffer, libfs, and mpage helpers that ext2 uses are all updated to
> > work with cgroup writeback.
> > 
> > This patch enables cgroup writeback for ext2 by adding
> > FS_CGROUP_WRITEBACK to its ->fs_flags.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: linux-ext4@vger.kernel.org
> 
> Hallelujah!
> 
> Reviewed-by: Jan Kara <jack@suse.com>

Hooray!  Thanks a lot for going through all the patches!  :)

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
