Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7425C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:38:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4392720854
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:38:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4392720854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983AB8E0003; Fri,  8 Mar 2019 02:38:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933C28E0002; Fri,  8 Mar 2019 02:38:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84A7B8E0003; Fri,  8 Mar 2019 02:38:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5B58E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 02:38:48 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h65so9787793wrh.16
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 23:38:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1XOvH1ZwcKfdCsQmFCknNIDKEgX2lwdmfDpwL/zvWFU=;
        b=aRIusLoMCRGkfWfjgTYf+svNeLWDZyEekRCrb8VXxqsHWJcQcUICmnaAx8MGILT02f
         HMRmYIoC7pgNyy/wMrKPECnhTwj0vxjvQwEPYllErKc3c8/Iv9tEWn/JgPz7yLC/XBt8
         plbPkrRpc21LNalH338ZHEhwIBhm5m3l32VuGxHT92ZbBNbw8RFnc/VbpU8lN59N8pop
         veF3q5GgzdsImmhoOuM6FfWWzjfMApGL5IaBtol27ZL60QZb6yE3ZuLYbQp9/48A4CxG
         Z6lCxYCZscvRYhUeMk01Uslht8zAe13W51EB8eEGKg+8LOBZdOGjFeYok+m8nibPTtBv
         3G2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAWkBbv3ukUmEidLzpqxJpwXbA66dGOq0m8A+leipfN7Q7YlXrQC
	RJhZbLZqMpoJSM/IGZQb/raAO7Akv8Sc1kMUNIIKrr2D7chwdAyJym+qe4SVGsz7y91+BngHmUm
	qmr3pucfrTJom0midCkOUKI2A/Ftq6T/c4TDU/36PEgCamuqMN1HoCLCLXQrK3g/C4O0SA9Yde6
	DQh0ZgwciAicjs3ugEq2VwTYAei1iwjwLZa2NqkdytMVeWyY+dJFf2c93i+Kqmj+Kyv0/9xmEcV
	EdN8nVlLbElWGiZ6k8F4CyOw2UxawMr4/UrZaLEcoveo4UOvlYcdsYuaAytxUesFk98NqfVbGcg
	owYsfkWQUuwdLsVzyY74dyi7v7RVC5TBqRThoVQ+3WlMWoTSfGTbkMRJf24eCRbeVX2a13Zhp4i
	VQTRDRvzHIWkc4v9VD3KxWOCv50hK9rzySfc49muTpSmIh4I/cpKqO6nDV+e8zxKyD01cwK+3j6
	f0OwBztLl5mrHZFz5y00sO1ZlgWn5HgQ0mI0v75HbYJJ/1+NNKMyLoC856BtoC3peqjApcnJVgc
	/FE0p+p8TU6i6cEGwhpVrul6QO9oNTPYEsIUxSlg/VD37I0KursdCD85lOQt2741sGiGJ8uzw36
	urHD2QaKxgag
X-Received: by 2002:adf:deca:: with SMTP id i10mr9217407wrn.312.1552030727746;
        Thu, 07 Mar 2019 23:38:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqwLI0ST7T6wGYj7PNrIkwrOPZW2xUvmf5lKGH4tgfhnxBqXcjneLt3lPREl+hy409tsGSw/
X-Received: by 2002:adf:deca:: with SMTP id i10mr9217358wrn.312.1552030726828;
        Thu, 07 Mar 2019 23:38:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552030726; cv=none;
        d=google.com; s=arc-20160816;
        b=tqLiaQdgUK2zQ54zM9O0c/6C0/kpgPfSywXnnWOqXuCGOHklKBMn4m6U15/1CYScL7
         mNZeXSrq1DwZKhzIaaVjwot1PK8uHkMetoFC/Vft/FQW+7gF/7xJawg0de+USNVs+V/B
         cynLQKfr1I7jwdxvEDH7+Mmet/Ggw1uJqy6VIrpj0QjOb5gNpKLQMc7wEAt0EwlyrcPg
         Ybul3nEkAi4PETNWcsRPasuyuMup8sd3Kmd1KQTpFug2DMBDGGThI1hYIwybTp0skXLk
         g9q9lC74Ru05kjpD6rG9SIHhnmh0ao9/SgyvTHR6e5bEBXIUfM6iwRMvxaY4S13A80I8
         fBqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1XOvH1ZwcKfdCsQmFCknNIDKEgX2lwdmfDpwL/zvWFU=;
        b=Q7U4l5mjBJ3Aq5mnpNkyeCFRQn2AqFWvAqMpGMbUzsYUbfKik7gv+v93nuF0qsSRcX
         iDcCT7fTyj5A4qwru3Vz00DUKXqLyxV/zPN/vzZ/kezKnhZksJdvB79sQ70SxhJeJr2U
         KFnuaUdtTk8uj/hstZr+PZ3JAeVBCmcjuHZA2kKGGf0pxyfemubjmiV6h77DZdX24MZI
         4gouwgIxO5AnLzS/acXwrcq5GxFA1VoT2oq0A4JPJ+A/aL5gyxzofRkR4cXmU1keZXfT
         4qm7LrorzDK+ndgs/N0Gk5JwZG0adXenXf786LaGuihgrYN36FAtOshT84g51LjEHBNt
         ZHhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id z18si5093889wrs.315.2019.03.07.23.38.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 23:38:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wm1-f69.google.com ([209.85.128.69])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h2A5d-0002zv-VG
	for linux-mm@kvack.org; Fri, 08 Mar 2019 07:38:45 +0000
Received: by mail-wm1-f69.google.com with SMTP id q126so3857309wme.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 23:38:45 -0800 (PST)
X-Received: by 2002:a1c:80d6:: with SMTP id b205mr8479025wmd.109.1552030725618;
        Thu, 07 Mar 2019 23:38:45 -0800 (PST)
X-Received: by 2002:a1c:80d6:: with SMTP id b205mr8478997wmd.109.1552030725252;
        Thu, 07 Mar 2019 23:38:45 -0800 (PST)
Received: from localhost (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id y1sm8080826wrh.65.2019.03.07.23.38.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 23:38:44 -0800 (PST)
Date: Fri, 8 Mar 2019 08:38:43 +0100
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/3] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190308073843.GA9732@xps-13>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190307180834.22008-2-andrea.righi@canonical.com>
 <20190307221051.ruhpp73q6ek2at3d@macbook-pro-91.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307221051.ruhpp73q6ek2at3d@macbook-pro-91.dhcp.thefacebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 05:10:53PM -0500, Josef Bacik wrote:
> On Thu, Mar 07, 2019 at 07:08:32PM +0100, Andrea Righi wrote:
> > Prevent priority inversion problem when a high-priority blkcg issues a
> > sync() and it is forced to wait the completion of all the writeback I/O
> > generated by any other low-priority blkcg, causing massive latencies to
> > processes that shouldn't be I/O-throttled at all.
> > 
> > The idea is to save a list of blkcg's that are waiting for writeback:
> > every time a sync() is executed the current blkcg is added to the list.
> > 
> > Then, when I/O is throttled, if there's a blkcg waiting for writeback
> > different than the current blkcg, no throttling is applied (we can
> > probably refine this logic later, i.e., a better policy could be to
> > adjust the throttling I/O rate using the blkcg with the highest speed
> > from the list of waiters - priority inheritance, kinda).
> > 
> > Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
> > ---
> >  block/blk-cgroup.c               | 131 +++++++++++++++++++++++++++++++
> >  block/blk-throttle.c             |  11 ++-
> >  fs/fs-writeback.c                |   5 ++
> >  fs/sync.c                        |   8 +-
> >  include/linux/backing-dev-defs.h |   2 +
> >  include/linux/blk-cgroup.h       |  23 ++++++
> >  mm/backing-dev.c                 |   2 +
> >  7 files changed, 178 insertions(+), 4 deletions(-)
> > 
> > diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> > index 2bed5725aa03..4305e78d1bb2 100644
> > --- a/block/blk-cgroup.c
> > +++ b/block/blk-cgroup.c
> > @@ -1351,6 +1351,137 @@ struct cgroup_subsys io_cgrp_subsys = {
> >  };
> >  EXPORT_SYMBOL_GPL(io_cgrp_subsys);
> >  
> > +#ifdef CONFIG_CGROUP_WRITEBACK
> > +struct blkcg_wb_sleeper {
> > +	struct backing_dev_info *bdi;
> > +	struct blkcg *blkcg;
> > +	refcount_t refcnt;
> > +	struct list_head node;
> > +};
> > +
> > +static DEFINE_SPINLOCK(blkcg_wb_sleeper_lock);
> > +static LIST_HEAD(blkcg_wb_sleeper_list);
> > +
> > +static struct blkcg_wb_sleeper *
> > +blkcg_wb_sleeper_find(struct blkcg *blkcg, struct backing_dev_info *bdi)
> > +{
> > +	struct blkcg_wb_sleeper *bws;
> > +
> > +	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
> > +		if (bws->blkcg == blkcg && bws->bdi == bdi)
> > +			return bws;
> > +	return NULL;
> > +}
> > +
> > +static void blkcg_wb_sleeper_add(struct blkcg_wb_sleeper *bws)
> > +{
> > +	list_add(&bws->node, &blkcg_wb_sleeper_list);
> > +}
> > +
> > +static void blkcg_wb_sleeper_del(struct blkcg_wb_sleeper *bws)
> > +{
> > +	list_del_init(&bws->node);
> > +}
> > +
> > +/**
> > + * blkcg_wb_waiters_on_bdi - check for writeback waiters on a block device
> > + * @blkcg: current blkcg cgroup
> > + * @bdi: block device to check
> > + *
> > + * Return true if any other blkcg different than the current one is waiting for
> > + * writeback on the target block device, false otherwise.
> > + */
> > +bool blkcg_wb_waiters_on_bdi(struct blkcg *blkcg, struct backing_dev_info *bdi)
> > +{
> > +	struct blkcg_wb_sleeper *bws;
> > +	bool ret = false;
> > +
> > +	spin_lock(&blkcg_wb_sleeper_lock);
> > +	list_for_each_entry(bws, &blkcg_wb_sleeper_list, node)
> > +		if (bws->bdi == bdi && bws->blkcg != blkcg) {
> > +			ret = true;
> > +			break;
> > +		}
> > +	spin_unlock(&blkcg_wb_sleeper_lock);
> > +
> > +	return ret;
> > +}
> 
> No global lock please, add something to the bdi I think?  Also have a fast path
> of

OK, I'll add a list per-bdi and a lock as well.

> 
> if (list_empty(blkcg_wb_sleeper_list))
>    return false;

OK.

> 
> we don't need to be super accurate here.  Thanks,
> 
> Josef

Thanks,
-Andrea

