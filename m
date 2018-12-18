Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B955D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 06:32:33 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so12264945edz.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:32:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gx11-v6si3673511ejb.297.2018.12.18.03.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 03:32:32 -0800 (PST)
Date: Tue, 18 Dec 2018 12:32:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181218113230.GI30879@dhcp22.suse.cz>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
 <20181217035157.GK10600@bombadil.infradead.org>
 <20181217093337.GC30879@dhcp22.suse.cz>
 <00ff5d2d-a50f-4730-db8a-cea3d7a3eef7@I-love.SAKURA.ne.jp>
 <5ba9aba1-e00d-ae07-caf0-3e7eca7de4b6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ba9aba1-e00d-ae07-caf0-3e7eca7de4b6@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hou Tao <houtao1@huawei.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Matthew Wilcox <willy@infradead.org>, phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 18-12-18 14:06:11, Hou Tao wrote:
[...]
> In my understanding (correct me if I am wrong), there are three ways through which
> reclamation will invoked fs related code and may cause dead-lock:
> 
> (1) write-back dirty pages. Not possible for squashfs.

only from kswapd context. So not relevant to OOM killer/

> (2) the reclamation of inodes & dentries. The current file is in-use, so it will be not
>     reclaimed, and for other reclaimable inodes, squashfs_destroy_inode() will
>     be invoked and it doesn't take any locks.

There are other inodes, not only those in use. Do you use any locks that
could be taken from an inode teardown?
-- 
Michal Hocko
SUSE Labs
