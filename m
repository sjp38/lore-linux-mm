Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8FCC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:07:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AE6F20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:07:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="hg7NUf0V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AE6F20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0627B8E0003; Thu,  7 Mar 2019 17:07:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F28B88E0002; Thu,  7 Mar 2019 17:07:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF67C8E0003; Thu,  7 Mar 2019 17:07:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B09078E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 17:07:04 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id l11so24927725ywl.18
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 14:07:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5XqGPOhHxWelDgT11+htERfFUnfLr39ckjM2oBzWcuM=;
        b=rz24F8TeyKWLFMsoDWGOUl4nTT097xfA8yCW1qfTXdDsPtuhGyaYhJgKbggJVrplpb
         K7DMBzhhbPMXZQF58FlsVSIrWHBguVDngmw31Sao7K6QFJc2Yn/08dCCqYXs+HYQoz74
         KJTeKkek1gGpXuZ7HwddywxhoxFggeIjf52eXWlrzwdY6EygG6xLJiyttHdSTDRIWxav
         QChbHoGkWSPb3ZqwhlvAXclScU0nTF/3RSJeLGJ9bieo9Ja9bjsVtClGR95xw/MpX0o0
         YXxu/jJ5toiaCUK27Y9EFCqulC0n4FIEuxCNQjDm1efZqzwq+dVXCBFYpSSWBA5hMS7s
         q4dA==
X-Gm-Message-State: APjAAAUiGJoOaCCbuQvCSjg3OKPWNqi4WYJkfGcEbf9Yc0ws09pQXLr3
	OAuLXQzFlojmNhFbaPkohVWfy+GuE0/i5Dy6Yp8KQckVxQV3B7y5w3Ct60DI4bLZnTQvKONxonD
	L9GkI3qMSqFa8MkXgcIELg/E9tLJ1bCO4k7t4f7cZDWoJbaAEyTlYuKTsqJxO5apVhJkYOyG5s8
	REEuom2e3Rnn8/9FjB7L9bv85nySbpXYDDeI/327+iJaRgBBLKweRr8DaZId+1jG8KYcMLN8iy1
	B7wk9HmmufVCeBX7pFRowiBRzpdOl+zGxAvGgj8tMjg0Gu9QdMYEGl6o5SpfsLKodBu5FpHf6ic
	qYTTMsuNhXi040ozo6V6nymQNSKinXYyYJS6g9FdB0ZtFgSXRpK3cpDHRdTZpuqfrD47RrhKBfG
	D
X-Received: by 2002:a5b:610:: with SMTP id d16mr13345384ybq.293.1551996424439;
        Thu, 07 Mar 2019 14:07:04 -0800 (PST)
X-Received: by 2002:a5b:610:: with SMTP id d16mr13345303ybq.293.1551996423308;
        Thu, 07 Mar 2019 14:07:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551996423; cv=none;
        d=google.com; s=arc-20160816;
        b=fuUwb7C4wZBA9tKQd12PJWZSptcANJPq0lvIVXAmHLKHDzeHje89Je/ASmZ310DFoY
         iNF4TzfVe+Qa/MkbWJQz3VwQ3iMGnUV2/4zHMIPDq+4MH/nG9WsCbHPjVjY8eJRlfQa6
         c3+GebITCsNMFMrn/2QlD9IfpDuIv39tzRbQ7OKUhBel4vy0ydlLBWJSw+DK/bPFLyS2
         hFijYcnhtDWMHXuaAXH/G9LA8q06L8DsMSPSPLJ9JsJ39nn8fmAD0RnxBXdEksnbHOSQ
         4Q7Ex7tWmNwsR0NNTaTO0IcW2nGNLGbew4he/CLr5fHQWyeNNis8Vj/BHoZfpNLJgt1f
         6uBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5XqGPOhHxWelDgT11+htERfFUnfLr39ckjM2oBzWcuM=;
        b=ULY9FepEOePV1FJ5irKBpln6z4rx/sVNHzFX0KhqP/XBN4Va06KZ+bgTH8x44j1Enx
         s/oedrkDUlPzp9bkTL5orOFw0kFKPbNzXJtepS5noET2sH+UajEgkEhfasYWw5EyqyTC
         tEHgVrDvlZ8cKgp5N1ZFuSA8Ov5+jEtOyUpnKHWmpSRgtS7JuKspxIjtCaYNHZqiijU0
         nQQWZugvzMJB8ixUcW8tcBuDV2vWMMpAIsmHMXN1XWYgMagdw0367Lylx08xdQTtfSzg
         ZZorHdDNwkKlVl3Dp7OiR1H/UQP8DnXa/9khgjJOfUoG+PRYHRwg3tsjQ1mmfZcWKDW/
         G/3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=hg7NUf0V;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor1137176ywf.215.2019.03.07.14.07.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 14:07:03 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=hg7NUf0V;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5XqGPOhHxWelDgT11+htERfFUnfLr39ckjM2oBzWcuM=;
        b=hg7NUf0VaR7rWE9ExshFRFdJUBKdlHgyhBWn7fpjNak6rkxf3itb5EAT/yLjZIgs5I
         PqLKwWBjIsOsCasCwpoEFwHh16ddfXVwzx9FvJOt76zVAt4KwA9lhQLTSvqp5aVi9nfp
         OLc7ZTSc9ofuBPPFhBVgn/JjmxwiAw9grGfKYve8t2h6dJP3YdzsJykQ137aLgGZcVQQ
         VrQpJ1IQzv2koxKRIhT5auG+a8z/d8jXn2c446S8wZ18mlVD4GQIa840ydnLLmZDEn/g
         lEWpO6x46h8n6/oPsjC6Pv+gSDsVjdOI2iSkuv6c3RhQmZsXH5qCpEjvo+HCT7qI+dgu
         iS0w==
X-Google-Smtp-Source: APXvYqxHCw18zCev+Plm9gMVQweneGhgqaylB5ml13zkDQOASfRadHyY4JnucJb5+loFSggeJzfBaQ==
X-Received: by 2002:a81:b8d:: with SMTP id 135mr12004691ywl.152.1551996422797;
        Thu, 07 Mar 2019 14:07:02 -0800 (PST)
Received: from localhost ([2620:10d:c091:180::be7f])
        by smtp.gmail.com with ESMTPSA id k187sm1953929ywc.47.2019.03.07.14.07.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 14:07:02 -0800 (PST)
Date: Thu, 7 Mar 2019 17:07:01 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <andrea.righi@canonical.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 3/3] blkcg: implement sync() isolation
Message-ID: <20190307220659.5qmye2pxmto7nlei@macbook-pro-91.dhcp.thefacebook.com>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190307180834.22008-4-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307180834.22008-4-andrea.righi@canonical.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 07:08:34PM +0100, Andrea Righi wrote:
> Keep track of the inodes that have been dirtied by each blkcg cgroup and
> make sure that a blkcg issuing a sync() can trigger the writeback + wait
> of only those pages that belong to the cgroup itself.
> 
> This behavior is applied only when io.sync_isolation is enabled in the
> cgroup, otherwise the old behavior is applied: sync() triggers the
> writeback of any dirty page.
> 
> Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
> ---
>  block/blk-cgroup.c         | 47 ++++++++++++++++++++++++++++++++++
>  fs/fs-writeback.c          | 52 +++++++++++++++++++++++++++++++++++---
>  fs/inode.c                 |  1 +
>  include/linux/blk-cgroup.h | 22 ++++++++++++++++
>  include/linux/fs.h         |  4 +++
>  mm/page-writeback.c        |  1 +
>  6 files changed, 124 insertions(+), 3 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 4305e78d1bb2..7d3b26ba4575 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -1480,6 +1480,53 @@ void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi)
>  	spin_unlock(&blkcg_wb_sleeper_lock);
>  	rcu_read_unlock();
>  }
> +
> +/**
> + * blkcg_set_mapping_dirty - set owner of a dirty mapping
> + * @mapping: target address space
> + *
> + * Set the current blkcg as the owner of the address space @mapping (the first
> + * blkcg that dirties @mapping becomes the owner).
> + */
> +void blkcg_set_mapping_dirty(struct address_space *mapping)
> +{
> +	struct blkcg *curr_blkcg, *blkcg;
> +
> +	if (mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK) ||
> +	    mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
> +		return;
> +
> +	rcu_read_lock();
> +	curr_blkcg = blkcg_from_current();
> +	blkcg = blkcg_from_mapping(mapping);
> +	if (curr_blkcg != blkcg) {
> +		if (blkcg)
> +			css_put(&blkcg->css);
> +		css_get(&curr_blkcg->css);
> +		rcu_assign_pointer(mapping->i_blkcg, curr_blkcg);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +/**
> + * blkcg_set_mapping_clean - clear the owner of a dirty mapping
> + * @mapping: target address space
> + *
> + * Unset the owner of @mapping when it becomes clean.
> + */
> +
> +void blkcg_set_mapping_clean(struct address_space *mapping)
> +{
> +	struct blkcg *blkcg;
> +
> +	rcu_read_lock();
> +	blkcg = rcu_dereference(mapping->i_blkcg);
> +	if (blkcg) {
> +		css_put(&blkcg->css);
> +		RCU_INIT_POINTER(mapping->i_blkcg, NULL);
> +	}
> +	rcu_read_unlock();
> +}
>  #endif
>  

Why do we need this?  We already have the inode_attach_wb(), which has the
blkcg_css embedded in it for whoever dirtied the inode first.  Can we not just
use that?  Thanks,

Josef

