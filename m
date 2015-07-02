Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCF16B0257
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 21:46:38 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so42685150qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:46:38 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id 78si4599454qkz.101.2015.07.01.18.46.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 18:46:37 -0700 (PDT)
Received: by qkbp125 with SMTP id p125so42662339qkb.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:46:37 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:46:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 30/51] writeback: implement and use inode_congested()
Message-ID: <20150702014634.GF26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
 <20150630152105.GP7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630152105.GP7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Tue, Jun 30, 2015 at 05:21:05PM +0200, Jan Kara wrote:
> Hum, is there any point in supporting NULL inode with inode_congested()?
> That would look more like a programming bug than anything... Otherwise the
> patch looks good to me so you can add:

Those are inherited from the existing usages and all for swapper
space.  I think we should have a dummy inode instead of scattering
NULL mapping->host test all over the place but that's for another day.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
