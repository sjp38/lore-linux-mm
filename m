Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id E664C6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 11:26:26 -0400 (EDT)
Received: by qcay5 with SMTP id y5so16477789qca.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 08:26:26 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id m34si13977984qgd.35.2015.03.31.08.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 08:26:25 -0700 (PDT)
Received: by qgfa8 with SMTP id a8so17538708qgf.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 08:26:25 -0700 (PDT)
Date: Tue, 31 Mar 2015 11:26:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET 1/3 v2 block/for-4.1/core] writeback: cgroup writeback
 support
Message-ID: <20150331152622.GD9974@htj.duckdns.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello, guys.

I updated all three patchsets to reflect the accumulated fixes and the
mapping_congested() change pointed out by Vivek, which BTW is now
inode_congested() - the whole function was a bit botched from
conversion from the multi-wb dirtying support, should be fine now.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150331
 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-backpressure-20150331
 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-switch-20150331

Jan, filesystem ppl, if you have any comments, please let me know;
otherwise, I'll post the next version of the patchset in a couple
days.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
