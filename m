Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB6A09003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:29:50 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so43263425qke.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:29:50 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id y72si4706314qgd.104.2015.07.01.19.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:29:50 -0700 (PDT)
Received: by qkbp125 with SMTP id p125so43168154qkb.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:29:50 -0700 (PDT)
Date: Wed, 1 Jul 2015 22:29:46 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 40/51] writeback: make bdi_start_background_writeback()
 take bdi_writeback instead of backing_dev_info
Message-ID: <20150702022946.GJ26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-41-git-send-email-tj@kernel.org>
 <20150701075009.GA7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701075009.GA7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed, Jul 01, 2015 at 09:50:09AM +0200, Jan Kara wrote:
> Can we add a memcg id of the wb to the tracepoint please? Because just bdi
> needn't be enough when debugging stuff...

Sure, will add cgroup path to identify the actual wb.  css IDs aren't
visible to userland.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
