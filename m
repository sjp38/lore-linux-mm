Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CC33C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:10:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CA9C20851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:10:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="pRDB0JKv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CA9C20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D07508E0003; Thu,  7 Mar 2019 17:10:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4B98E0002; Thu,  7 Mar 2019 17:10:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3EE8E0003; Thu,  7 Mar 2019 17:10:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7B48E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 17:10:56 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id d64so10260782ywa.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 14:10:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8fGHXDrETn6TabDK8suVxtfSni42P/yTtu2dStlmLK0=;
        b=A/UW715xMsMqY/E4Dx6l5nA2+V8ok0tOQTo2MMKNhb2dzZHKABuqIItttZlbLDRk8V
         xXqm2ksD3/DctMB4VArXK8TfpLYW6EPm9fvowpkP1Ro7YVCF7pVvkv308Nus+zoDFzWl
         jKFooTSmXYe07eI69pBmODtfQOlM/M6L2felh5vTjrwamXWXt8uHuIZqwyht3dyUb5YI
         W1FXy4FHdaUxOGxW4Iv+iIUw5RPlFjkUy0bjsLg2LmsJcCHB5n68RMF3hhXElj+BLxqV
         pZDVpBwoUD7Ge/w5kbkmiA8m9QURxlkETLdFDq6BwdSeoSvccR0tGoOTwpg9w/DMEey7
         8Dzw==
X-Gm-Message-State: APjAAAWI/Ul+up+YmghRjKQyFqbWknnDYrJsMIMQX5adAfcMcr/Ou6Vr
	0pbBg2udQ1gRU4elGpkCdGbZK+mImBGWRdL/r7Mw3nwgQrA51njO4Lne83MKs59dVx89R9pz4ic
	QctvuXnzz/3kjGm/iRQ9u+4UxVdipTItLYgmF39svQ2cjbcZwkeSKpO/V17nMnLT8jJAKt0JcBQ
	6fuXv/eE4+nHzFHCqCMy8g+T729BSJ/xNPvXDZVXD25SOdV2jm5jjG/d8Tyu1z5v2D8zUYbvg7n
	6MyTHT1mWOcrlmFCHhNAM9TQzbuJLQzMnBve5/8tUSqQWuwyY+gO1RESOx0ICmNNgq2F4ukunb1
	vVNw9sXrx0mgKwyR+CEE+rDgycEZJ37Rru3bu7AE7NUcbBY9hu7kZ1Wub0gZTnWMLGzq8xfWq4E
	U
X-Received: by 2002:a25:9d90:: with SMTP id v16mr13405015ybp.16.1551996656308;
        Thu, 07 Mar 2019 14:10:56 -0800 (PST)
X-Received: by 2002:a25:9d90:: with SMTP id v16mr13404962ybp.16.1551996655542;
        Thu, 07 Mar 2019 14:10:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551996655; cv=none;
        d=google.com; s=arc-20160816;
        b=Yys3EBcSHV2z6uXrcH1pQ8W1zgzKWYSIBuKmJgfaunRd0YICIcZmoHnbk/qsftvIew
         MU+xwujSK6nqQG5FjEhy/nTWeeC+EH6OEL7bQ9jJtfl9gYcp81zFAviPTPXnkZ9jko+C
         VaaoHA/pf049ZWESHOjtQB7lqAQEMDx9eIwBHfX6gxCKFfALa9q1Fygkl7uVX14Ak7CZ
         hzHkM+efsoc7wgydp+OxEH/ZrdzPCkomdurlJkrKFSu9VoflOcIeUh0aiJXVQD03tZFs
         Sj9bnXNrivP5C3iKFioQZDGto9qJVbgDatmi9rWeDQ0wz3u/PAzs/mUlC8AiqLNx1dOz
         168Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8fGHXDrETn6TabDK8suVxtfSni42P/yTtu2dStlmLK0=;
        b=H7W4XWOEYb1R8+2C0yhCJLF3Y776Hmu4wmj3kve9arEshXKwDqQ5M3X4W2d9rD7mEB
         KSyTWOqQip0ECwaqluNjcxxZVVL6wE2/RatDYHo4MyMsnI1Z0eui9Ru6Yj5e7LonTXm8
         iJqfaO4fAzilGSrJI+2X1RaLti144MxIprihy/SjDuRACIYf/AlaTAA92HNVEMkhnkG1
         QAg1aymvZAVGC43+btWGde5YBEYQn46Yhyc4Ne89M7tKA98Zc7GxfZtTpCydgGupT+Ow
         nBmHqWuUfuC0EGbqMGVsykd1pTJ5qDLjkVdq9Kjd8RjuS0zUBdtbwqbs3Hasc68cy4I8
         R1YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=pRDB0JKv;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l186sor864220ywd.189.2019.03.07.14.10.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 14:10:55 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=pRDB0JKv;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8fGHXDrETn6TabDK8suVxtfSni42P/yTtu2dStlmLK0=;
        b=pRDB0JKvv6tfCYaEfKCrtyA9qWFops5hSVOSCIKoMjRZ/2pUEGPrm43Yg8eHyZqGLo
         bDtAHEnXTR6S8mX6lw3KG6Cnnj3/hXrUgxK5rn8VAgOVF6jEb21BOQPG9cDo6XGau6s2
         EVGFn9Q5O3qkEyzwYodtWUgwjlUaESCsgNk9RUd8OCiD3901qrlmJAr4ejrkA9ewJBSK
         Hm2sLgFU94ViOLL6VelFwkO+AKCqBJSng3uZRY6Dh19x2k/6k7xXuB1ipPY9ZAH9MMYh
         xhqd1PIGWTdoOWjcTUAvTXHra8ML2DyEmQdZF3UtrMRo0NBpfPylt1DEpI56lQx2M0/G
         hPpw==
X-Google-Smtp-Source: APXvYqxlY6+6icUcEkNYdZXTYelR9T0cimRfsKU9w2fu3lPODj9S1XiDdChJgoV3OHlgLOn8mLi7Eg==
X-Received: by 2002:a81:a091:: with SMTP id x139mr12347457ywg.164.1551996655114;
        Thu, 07 Mar 2019 14:10:55 -0800 (PST)
Received: from localhost ([2620:10d:c091:180::be7f])
        by smtp.gmail.com with ESMTPSA id h131sm2126941ywa.81.2019.03.07.14.10.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 14:10:54 -0800 (PST)
Date: Thu, 7 Mar 2019 17:10:53 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <andrea.righi@canonical.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/3] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190307221051.ruhpp73q6ek2at3d@macbook-pro-91.dhcp.thefacebook.com>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190307180834.22008-2-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307180834.22008-2-andrea.righi@canonical.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 07:08:32PM +0100, Andrea Righi wrote:
> Prevent priority inversion problem when a high-priority blkcg issues a
> sync() and it is forced to wait the completion of all the writeback I/O
> generated by any other low-priority blkcg, causing massive latencies to
> processes that shouldn't be I/O-throttled at all.
> 
> The idea is to save a list of blkcg's that are waiting for writeback:
> every time a sync() is executed the current blkcg is added to the list.
> 
> Then, when I/O is throttled, if there's a blkcg waiting for writeback
> different than the current blkcg, no throttling is applied (we can
> probably refine this logic later, i.e., a better policy could be to
> adjust the throttling I/O rate using the blkcg with the highest speed
> from the list of waiters - priority inheritance, kinda).
> 
> Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
> ---
>  block/blk-cgroup.c               | 131 +++++++++++++++++++++++++++++++
>  block/blk-throttle.c             |  11 ++-
>  fs/fs-writeback.c                |   5 ++
>  fs/sync.c                        |   8 +-
>  include/linux/backing-dev-defs.h |   2 +
>  include/linux/blk-cgroup.h       |  23 ++++++
>  mm/backing-dev.c                 |   2 +
>  7 files changed, 178 insertions(+), 4 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 2bed5725aa03..4305e78d1bb2 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -1351,6 +1351,137 @@ struct cgroup_subsys io_cgrp_subsys = {
>  };
>  EXPORT_SYMBOL_GPL(io_cgrp_subsys);
>  
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +struct blkcg_wb_sleeper {
> +	struct backing_dev_info *bdi;
> +	struct blkcg *blkcg;
> +	refcount_t refcnt;
> +	struct list_head node;
> +};
> +
> +static DEFINE_SPINLOCK(blkcg_wb_sleeper_lock);
> +static LIST_HEAD(blkcg_wb_sleeper_list);
> +
> +static struct blkcg_wb_sleeper *
> +blkcg_wb_sleeper_find(struct blkcg *blkcg, struct backing_dev_info *bdi)
> +{
> +	struct blkcg_wb_sleeper *bws;
> +
> +	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
> +		if (bws->blkcg == blkcg && bws->bdi == bdi)
> +			return bws;
> +	return NULL;
> +}
> +
> +static void blkcg_wb_sleeper_add(struct blkcg_wb_sleeper *bws)
> +{
> +	list_add(&bws->node, &blkcg_wb_sleeper_list);
> +}
> +
> +static void blkcg_wb_sleeper_del(struct blkcg_wb_sleeper *bws)
> +{
> +	list_del_init(&bws->node);
> +}
> +
> +/**
> + * blkcg_wb_waiters_on_bdi - check for writeback waiters on a block device
> + * @blkcg: current blkcg cgroup
> + * @bdi: block device to check
> + *
> + * Return true if any other blkcg different than the current one is waiting for
> + * writeback on the target block device, false otherwise.
> + */
> +bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
> +{
> +	struct blkcg_wb_sleeper *bws;
> +	bool ret = false;
> +
> +	spin_lock(&blkcg_wb_sleeper_lock);
> +	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
> +		if (bws->bdi == bdi && bws->blkcg != blkcg) {
> +			ret = true;
> +			break;
> +		}
> +	spin_unlock(&blkcg_wb_sleeper_lock);
> +
> +	return ret;
> +}

No global lock please, add something to the bdi I think?  Also have a fast path
of

if (list_empty(blkcg_wb_sleeper_list))
   return false;

we don't need to be super accurate here.  Thanks,

Josef

