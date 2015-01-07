Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D337F6B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 09:19:59 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so5128282pab.7
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:19:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id pm2si3450137pdb.18.2015.01.07.06.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 06:19:58 -0800 (PST)
Date: Wed, 7 Jan 2015 06:19:45 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHSET v2 block/for-next] writeback: prepare for cgroup
 writeback support
Message-ID: <20150107141945.GA29680@infradead.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz

This needs a rebase over my "backing_dev_info cleanups" series, which
starts to sort out the bdi lifetime issues.  I think this series is
fine to go over just that, but before any bigger bdi changes we'll
also need to sort out the rest of the lifetime issues.  I have some
WIP patches for that which I'll be able to post soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
