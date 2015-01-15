Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 90EFA6B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:55:47 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id b13so2729180qcw.7
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:55:47 -0800 (PST)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id w3si3093142qaj.20.2015.01.15.10.55.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 10:55:46 -0800 (PST)
Received: by mail-qg0-f44.google.com with SMTP id l89so4424971qgf.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:55:46 -0800 (PST)
Date: Thu, 15 Jan 2015 13:55:43 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/6] memcg: track shared inodes with dirty pages
Message-ID: <20150115185543.GA28195@htj.dyndns.org>
References: <20150115180242.10450.92.stgit@buzz>
 <20150115184914.10450.51964.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115184914.10450.51964.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

On Thu, Jan 15, 2015 at 09:49:14PM +0300, Konstantin Khebnikov wrote:
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Inode is owned only by one memory cgroup, but if it's shared it might
> contain pages from multiple cgroups. This patch detects this situation
> in memory reclaiemer and marks dirty inode with flag I_DIRTY_SHARED
> which is cleared only when data is completely written. Memcg writeback
> always writes such inodes.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This conflicts with the writeback cgroup support patchset which will
solve the writeback and memcg problem a lot more comprehensively.

 http://lkml.kernel.org/g/1420579582-8516-1-git-send-email-tj@kernel.org

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
