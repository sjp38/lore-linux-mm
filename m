Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 816836B00CC
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:07:38 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31156699qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:07:38 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id k62si5156804qgk.87.2015.04.06.13.07.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:07:37 -0700 (PDT)
Received: by qgej70 with SMTP id j70so15057381qge.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:07:37 -0700 (PDT)
Date: Mon, 6 Apr 2015 16:07:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET 2/3 v2 block/for-4.1/core] writeback: cgroup writeback
 backpressure propagation
Message-ID: <20150406200734.GI10582@htj.duckdns.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon, Apr 06, 2015 at 04:04:15PM -0400, Tejun Heo wrote:
> [L] http://lkml.kernel.org/g/
> [1] http://lkml.kernel.org/g/20150323041848.GA8991@htj.duckdns.org
> [2] http://lkml.kernel.org/g/

Oops, forgot to update the links.

[L] http://lkml.kernel.org/g/1428350674-8303-1-git-send-email-tj@kernel.org
[1] http://lkml.kernel.org/g/20150323041848.GA8991@htj.duckdns.org
[2] http://lkml.kernel.org/g/1428350318-8215-1-git-send-email-tj@kernel.org

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
