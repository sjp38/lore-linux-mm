Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 957F66B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 02:13:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k81so1463361pfg.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 23:13:55 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f6si887978pgr.45.2017.06.06.23.13.53
        for <linux-mm@kvack.org>;
        Tue, 06 Jun 2017 23:13:54 -0700 (PDT)
Date: Wed, 7 Jun 2017 15:12:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Revert "mm: vmpressure: fix sending wrong events on
 underflow"
Message-ID: <20170607061216.GA5929@bbox>
References: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com>
 <20170607035540.GA5687@bbox>
 <59378799.1050000@huawei.com>
MIME-Version: 1.0
In-Reply-To: <59378799.1050000@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vinayakm.list@gmail.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 07, 2017 at 12:56:57PM +0800, zhong jiang wrote:
> On 2017/6/7 11:55, Minchan Kim wrote:
> > On Wed, Jun 07, 2017 at 11:08:37AM +0800, zhongjiang wrote:
> >> This reverts commit e1587a4945408faa58d0485002c110eb2454740c.
> >>
> >> THP lru page is reclaimed , THP is split to normal page and loop again.
> >> reclaimed pages should not be bigger than nr_scan.  because of each
> >> loop will increase nr_scan counter.
> > Unfortunately, there is still underflow issue caused by slab pages as
> > Vinayak reported in description of e1587a4945408 so we cannot revert.
> > Please correct comment instead of removing the logic.
> >
> > Thanks.
>   we calculate the vmpressue based on the Lru page, exclude the slab pages by previous
>   discussion.    is it not this?
> 

IIRC, It is not merged into mainline although mmotm has it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
