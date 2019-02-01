Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4115BC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F20752146E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 22:48:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CbxmDTo/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F20752146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CA438E0009; Fri,  1 Feb 2019 17:48:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 850998E0001; Fri,  1 Feb 2019 17:48:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CB528E0009; Fri,  1 Feb 2019 17:48:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 225D58E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 17:48:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l76so6854033pfg.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 14:48:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=URMAPqFQyyslJ0IeDQ0Bnp5duEOnoAiucGaK8+JCWxg=;
        b=jdZuN/FVOgThJ6h3b345wARutFfR20ILUfn1EGPnWOSQl/eReyonJuLXsWF8BBA44u
         VP3qsywZxqLq9wV9NUT+XWg2yB8JS5XxLHADBDq3cuRlybIHOzdcztit9GR+7kg3CCxG
         eUKa4vHMgGe0Jz6cISgpJ6JHwmDxea+PNijeOfxGZA7KYZv/Y4QAw9F/YfQ5CWt8fQGS
         iqbh1Lu7LogAZmCXfAUiWfVx+xULWfKnjHghHHbYPqNoZktcKD7tWUmGIFDJSaqhswVp
         omr8SjPLBfWvfzxFNTifQkWoJxNhFF3lYV/k+bZ3/VU5gPr2a5w+4XV12cPcNMfIzkZH
         bH8A==
X-Gm-Message-State: AJcUukea4iSsT+oHbbq4cgeZdOahx6rrDNFoXxv4HsbOYZ7W54ZlLtgX
	MoEgpWgKJWKnCt0DEFlV2w1Xlurl5AD8sK6WoJDa6fHkrTv9qpoCSiPteCHONmCbvqiCw1DDTe4
	jZrwNRXCLe40lcsSWcaq/e1VF1SU2L4nP08Nph6jsCqWt/LbPy6flWdw6iXhC3M9vy6jiwW+lYm
	W6f+QQ4ptliI4N9exTQX9GPUnppsNlvgNAGpgBzg21dYG1UEzHDI8opK1BhQxb/JRfMxLZzP/A1
	zrF+EaJRemcaqrkjMmLCu9lV0i446p33+ihM6P1wGOLGQSn8fMAEv5R7qTXwWKWrTY07voodqBQ
	q68eIVvsj9U0qAAGp44AIuJfEWNmj+jY5tBSF+J1FOQSlHIyLttU/1ekZnqopUE/3lcyxY1Iuqu
	l
X-Received: by 2002:a17:902:1126:: with SMTP id d35mr39093606pla.1.1549061295665;
        Fri, 01 Feb 2019 14:48:15 -0800 (PST)
X-Received: by 2002:a17:902:1126:: with SMTP id d35mr39093571pla.1.1549061295001;
        Fri, 01 Feb 2019 14:48:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549061294; cv=none;
        d=google.com; s=arc-20160816;
        b=rv1Akt9elASfsXgG4Fxfjo27cxXegddob0QCqwplZnBIys1KY5nSzr2GW4sVl8wxWu
         zQrEa3BHpRTyEp+0g0cn2abqicrawKJE7erWOq4gHYyQd/pfBBbv8lscd6Abuo+Z/QJm
         uhyIgUGcSRnoWNnWZI310Q//T4+EMt842lJHQ1sUtwGq5js1fz8HFUM1zNP0nHItb4NP
         6+ZE211hSUwY+zyl8kmgHXx5EK8SxqI7xwmXcQEIfsRIfwjDr18eXq96Pzyim/lJda9q
         mH2W/P+f+TSRpCtuc3HA55YoiRFe5yFk7zIVMdSX+0PVnItAzalLIwmpgGzuX7CBlL1h
         WZGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=URMAPqFQyyslJ0IeDQ0Bnp5duEOnoAiucGaK8+JCWxg=;
        b=Discrom4eUmX51WGLAeX5PIkgoWFI4mOx6i/ZRhb/ffI8hAJ4VrLo5r1+Df5K56IXc
         gti4MZ3XbUseYdjCbiK/sliVtjU7mIpq+cNCCYVh/Fn7hFRUEAtjdVNKS882RUu5fvxw
         m7YJv5MgvHMIk/NVQwvBimkbwq4gLTfW/Q+EibSn9+TGLNLkdLRpUh3HTPvMlogqr6Jv
         Wz3RS/VzAxg31gx776pZ09otd/UGR6KXeE1xz/jkQH3FeM+kKEgzenlyjFRtBTNI3xDc
         67rSxoiwRqSXUuwd4n61NgkSmdJoxv/isC6Utzj4HsnVWa6u+2pbo2wW0mVKpCz3KYxX
         wKvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="CbxmDTo/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor13963760plh.10.2019.02.01.14.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 14:48:14 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="CbxmDTo/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=URMAPqFQyyslJ0IeDQ0Bnp5duEOnoAiucGaK8+JCWxg=;
        b=CbxmDTo/8rDjmVQ+Bcjl3YLfE+0f6KmR9G2hcDKaPyrzzBvrS58yYVretEqOIuJBDI
         Ye9kqjuEZGAYIBzrCqwBdaLKbTQiWHPrWYSXwVVmybrBw9oeoQN8hKe/ePJS/DUpZoHA
         u+dSLjno/lBYnYZJ36O83INJ40suVf92Nz4GR4Lkwx2pubEfudhiDSzUsQV5EvvZsDrA
         FHILw4e5aZRbxJEMEB7lCrmcdDRSTwQSKG9ecVlPdtXbtXBx4v6yGKfnXhfJJS5RpLRY
         3zxhIEOrP+OOX03JICevSnJubGDP8UxtcMUyNJC6WuLjdBLd6QdbvHEs8/YFg7kyRRub
         q7VQ==
X-Google-Smtp-Source: ALg8bN6VXHFBWGU3dis7ET91Cl+ArcYT0LKU23YQaxNvXPQUwnUCWa9aM6/jwUV4v8PUgmx5X724+A==
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr40181978pla.144.1549061293937;
        Fri, 01 Feb 2019 14:48:13 -0800 (PST)
Received: from localhost (14-202-194-140.static.tpgi.com.au. [14.202.194.140])
        by smtp.gmail.com with ESMTPSA id 62sm9180955pgc.61.2019.02.01.14.48.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Feb 2019 14:48:13 -0800 (PST)
Date: Sat, 2 Feb 2019 09:48:09 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: kbuild test robot <lkp@intel.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 5141/5361] include/linux/hmm.h:102:22: error:
 field 'mmu_notifier' has incomplete type
Message-ID: <20190201224809.GK26056@350D>
References: <201902020011.aV3IBiMH%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902020011.aV3IBiMH%fengguang.wu@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 02, 2019 at 12:14:13AM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
> commit: a3402cb621c1b3908600d3f364e991a6c5a8c06e [5141/5361] mm/hmm: improve driver API to work and wait over a range
> config: x86_64-randconfig-b0-02012138 (attached as .config)
> compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
> reproduce:
>         git checkout a3402cb621c1b3908600d3f364e991a6c5a8c06e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from kernel/memremap.c:14:
> >> include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomplete type
>      struct mmu_notifier mmu_notifier;
>                          ^~~~~~~~~~~~
> 
> vim +/mmu_notifier +102 include/linux/hmm.h
> 
>     81	
>     82	
>     83	/*
>     84	 * struct hmm - HMM per mm struct
>     85	 *
>     86	 * @mm: mm struct this HMM struct is bound to
>     87	 * @lock: lock protecting ranges list
>     88	 * @ranges: list of range being snapshotted
>     89	 * @mirrors: list of mirrors for this mm
>     90	 * @mmu_notifier: mmu notifier to track updates to CPU page table
>     91	 * @mirrors_sem: read/write semaphore protecting the mirrors list
>     92	 * @wq: wait queue for user waiting on a range invalidation
>     93	 * @notifiers: count of active mmu notifiers
>     94	 * @dead: is the mm dead ?
>     95	 */
>     96	struct hmm {
>     97		struct mm_struct	*mm;
>     98		struct kref		kref;
>     99		struct mutex		lock;
>    100		struct list_head	ranges;
>    101		struct list_head	mirrors;
>  > 102		struct mmu_notifier	mmu_notifier;

Only HMM_MIRROR depends on MMU_NOTIFIER, but mmu_notifier in
the hmm struct is not conditionally dependent HMM_MIRROR.
The shared config has HMM_MIRROR disabled

Balbir

