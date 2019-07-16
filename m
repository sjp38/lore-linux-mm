Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F21EC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 18:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33322145D
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 18:23:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="IhLxXmaA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33322145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FBEC6B0005; Tue, 16 Jul 2019 14:23:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AC728E0006; Tue, 16 Jul 2019 14:23:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19BA68E0003; Tue, 16 Jul 2019 14:23:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECF496B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 14:23:35 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id j81so17620187qke.23
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=9PXyjImG+E2TkTA05zWl+KvbpavQKqjXD6/g7c5TTGc=;
        b=gDvLw1HILIG65UtOMv30BdTwasmi4C+so5P55gheE+XFbama7vhYhiCvYJaUESDM7K
         ePY702qXNQme5Ft/YizK4ChBf1llRfN1YX7G17HmmiMLVgsDG7hG2xfHe9llW6mrMBAE
         v0OgcaXfeZzlXCNRPKXjz9ltTUUMNtNOSX4s9DZANAJ+J7MijKBqClsGFLJrc4UvrUR2
         8nMq3ZPKQzzbkYa4cQIYzb3GLOydh7AKnku1xyB1IBFqMnHn2banEtUfjNTzZuCDRleu
         YM2V6feOU8cMbfbhbyfSImKGvW05KqUUTqt/lhHtaindm/EwOJAxXSkGGOG8TBfpEGls
         fp6g==
X-Gm-Message-State: APjAAAUEoRcwoT5ugVQocjmLl54sv78YMXP/dzFA6N0I3/qrfVO7EeeI
	jqlZMP3F/X1JjLJ49cVvSbZ6Um7r6r+nXOfhQEJhpO7nBj1sfWu8DYMLdhRXS8Pao+b7Venopiu
	NPCRzza/TheSWY2h4AkkBtN18b6hAyUTtahCdzgumdFz7+HM34lt92qU9huc+Ium+dw==
X-Received: by 2002:ac8:5141:: with SMTP id h1mr24471253qtn.15.1563301415669;
        Tue, 16 Jul 2019 11:23:35 -0700 (PDT)
X-Received: by 2002:ac8:5141:: with SMTP id h1mr24471214qtn.15.1563301414836;
        Tue, 16 Jul 2019 11:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563301414; cv=none;
        d=google.com; s=arc-20160816;
        b=oVUQklLq3mG8S62TbZ9aEhwP1NW7Xl9baKCQVG3gMz39vtH4a1ds8sEOZK1UxKK9I4
         PSNR8f43Kjy3N8a7+I5AYL3jZOA9reQ3r054eDKFBhkdyvayOc2Gs31ZW9QdLo11lNKL
         hQCMWzKp0axEbMrNx4KGOnVBVw9J/vNXtWnaCKvnNOvbyv4YDyoTndUEwYsCDpOjsnyw
         8r2UgiUUBC5ClUgQOy1ps+wU5xODAZkfOGi6S8KKribhV9QbmXWPB6DTrRfI/AD7Yeag
         Thtz3JGS/laKM280yREEyFIr1olpLWbJEbPcc6tbBapJcN3lq2O/9Z1VGwZEfO0A+zVn
         nUYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=9PXyjImG+E2TkTA05zWl+KvbpavQKqjXD6/g7c5TTGc=;
        b=tDNlw1YKuExuG86cxSacaQa9Ik6o40H1a2jR9cnMBL/YFcLFk7qq7JaUKEfcLkYYYO
         K2qeIMZP+dgbom5Rtgs2r8Edi72pfe+GW/6KqSUEpQUslfnWxbynfOkOjcR5Wu0Gqg4d
         ScS/zh6jORA46YPkTObF6mzElXPweYzi6cvRwEUc2sjOOrMG5UA/XWeiKyQSsgw4iHRi
         TFL3joZf1KBuKuFhXVYfmIPvLuO8WX/vICWgm+zOBXQqU9sBBBN0HyBs9qJoB3lyw4uM
         G5wd03Xtbxcgz776pVCF6ir+gqazUHEnWp86brnt2wFJ59x/Om7Ro9rdjRgBRAKSLPAH
         QtWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IhLxXmaA;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor28991496qto.35.2019.07.16.11.23.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 11:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IhLxXmaA;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=9PXyjImG+E2TkTA05zWl+KvbpavQKqjXD6/g7c5TTGc=;
        b=IhLxXmaA7lR5yGh01DUyd6sYT6E6n/2RktpucRSVoywo/da4UJzZVb+36q4q9LQiBA
         nQl1A096NEc6LX/dIxZIyjWD/viMWA9keetJjhAfeSgudlVR3654CZqnAMrI3Ak53cti
         1la2hb6mTk05I+FnisbYcZ0W9myAguoW3dCElTpW0rDs84LUZAE13bz0LdigEwOCKHvu
         RyHcXhqu67ObXKD+rH6ivxLHutxFVFcv3S5V5poRAtqA0ye+SSH1DkNGj/wWAY7Z53cg
         r1ogSUE4y7itkqz3hpwRgZaCjLxac5lr0NVU1//eO1X9i3NZ2RYQAOQgeFCLFNgcsv3y
         XjdA==
X-Google-Smtp-Source: APXvYqwDiPkO01x0v4gYkA8ROVKOZtnYbXXoSXCZbHBDGqMxSo60v4pBhZjuyNrG/7jica7ztAWnyg==
X-Received: by 2002:ac8:877:: with SMTP id x52mr24045228qth.328.1563301414529;
        Tue, 16 Jul 2019 11:23:34 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id r40sm11907517qtr.57.2019.07.16.11.23.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 11:23:33 -0700 (PDT)
Message-ID: <1563301410.4610.8.camel@lca.pw>
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
From: Qian Cai <cai@lca.pw>
To: Yang Shi <yang.shi@linux.alibaba.com>, catalin.marinas@arm.com, 
 mhocko@suse.com, dvyukov@google.com, rientjes@google.com,
 willy@infradead.org,  akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 16 Jul 2019 14:23:30 -0400
In-Reply-To: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-17 at 01:50 +0800, Yang Shi wrote:
> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:
> 
> WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608
> __alloc_pages_nodemask+0x1c31/0x1d50
> Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs
> virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring
> virtio libata
> CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-
> g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
> ...
>  kmemleak_alloc+0x4e/0xb0
>  kmem_cache_alloc+0x2a7/0x3e0
>  ? __kmalloc+0x1d6/0x470
>  ? ___might_sleep+0x9c/0x170
>  ? mempool_alloc+0x2b0/0x2b0
>  mempool_alloc_slab+0x2d/0x40
>  mempool_alloc+0x118/0x2b0
>  ? __kasan_check_read+0x11/0x20
>  ? mempool_resize+0x390/0x390
>  ? lock_downgrade+0x3c0/0x3c0
>  bio_alloc_bioset+0x19d/0x350
>  ? __swap_duplicate+0x161/0x240
>  ? bvec_alloc+0x1b0/0x1b0
>  ? do_raw_spin_unlock+0xa8/0x140
>  ? _raw_spin_unlock+0x27/0x40
>  get_swap_bio+0x80/0x230
>  ? __x64_sys_madvise+0x50/0x50
>  ? end_swap_bio_read+0x310/0x310
>  ? __kasan_check_read+0x11/0x20
>  ? check_chain_key+0x24e/0x300
>  ? bdev_write_page+0x55/0x130
>  __swap_writepage+0x5ff/0xb20
> 
> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak has
> __GFP_NOFAIL set all the time due to commit
> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> with fault injection").  But, it doesn't make any sense to have
> __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same time.
> 
> According to the discussion on the mailing list, the commit should be
> reverted for short term solution.  Catalin Marinas would follow up with a
> better
> solution for longer term.
> 
> The failure rate of kmemleak metadata allocation may increase in some
> circumstances, but this should be expected side effect.

As mentioned in anther thread, the situation for kmemleak under memory pressure
has already been unhealthy. I don't feel comfortable to make it even worse by
reverting this commit alone. This could potentially make kmemleak kill itself
easier and miss some more real memory leak later.

To make it really a short-term solution before the reverting, I think someone
needs to follow up with the mempool solution with tunable pool size mentioned
in,

https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.com/

I personally not very confident that Catalin will find some time soon to
implement embedding kmemleak metadata into the slab. Even he or someone does
eventually, it probably need quite some time to test and edge out many of corner
cases that kmemleak could have by its natural.

> 
> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Qian Cai <cai@lca.pw>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/kmemleak.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9dd581d..884a5e3 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -114,7 +114,7 @@
>  /* GFP bitmask for kmemleak internal allocations */
>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) |
> \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN)
>  
>  /* scanning area inside a memory block */
>  struct kmemleak_scan_area {

