Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4618D6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:13:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so213045549pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:13:50 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id fi15si39385508pac.191.2016.01.05.02.13.49
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 02:13:49 -0800 (PST)
Date: Tue, 5 Jan 2016 10:13:43 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: fix add kasan bug
Message-ID: <20160105101342.GB14545@localhost.localdomain>
References: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
 <20160104131333.6603ea788a59150e728970f2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104131333.6603ea788a59150e728970f2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhongjiang <zhongjiang@huawei.com>, linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com, linux-mm@kvack.org, qiuxishi@huawei.com, long.wanglong@huawei.com, Will Deacon <will.deacon@arm.com>

On Mon, Jan 04, 2016 at 01:13:33PM -0800, Andrew Morton wrote:
> On Thu, 31 Dec 2015 18:09:09 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
> 
> > From: zhong jiang <zhongjiang@huawei.com>
> > 
> > In general, each process have 16kb stack space to use, but
> > stack need extra space to store red_zone when kasan enable.
> > the patch fix above question.
> 
> Thanks.  I grabbed this, but would prefer that the arm64 people handle
> it?

I would also prefer taking such fix via the arm64 tree, though we are
currently still going through the post-holiday email backlog.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
