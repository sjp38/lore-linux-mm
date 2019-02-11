Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3055AC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:39:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E198E222A7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="Cz7C/op5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E198E222A7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A908E00EB; Mon, 11 Feb 2019 10:39:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E39A8E00E9; Mon, 11 Feb 2019 10:39:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7858F8E00EB; Mon, 11 Feb 2019 10:39:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4417E8E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:39:20 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id c67so8063063ywe.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:39:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=boQyFNiX0XoZWerTpTg2C8lpdchzW9CQNXvCXi3hMik=;
        b=pzdTrhSYHrhzqI41uph6bGd8GY848FRdHkQMC8qdFbgpvCcKoBrEP7KjqKIV0Y1Wgj
         Tv6OHcC8BiaLgM6edM57NHplM/SrFAoqsBkwSW7OtXmozJ/r6ACkAkKgJH0jP5/5OvtO
         jjBRCEu+EdWACNRSM5s34Fx6qnjHpJq/V16LxvN6RxFLrPTa56Mizufq0eLmZ13rbybK
         Y+JOQu6/ZGYEp+T1Osp0649sFKJYLqoUsez2TrIiaOzEbkFgRTVtvGEsA6oCzTDMQ0rK
         TP13Zj4fr3X8/HXil77MVrY1/VjS7iPFNKaXxEE/T8Qz5sxE0IH5ZRYlNMaEEw10wukL
         8w7g==
X-Gm-Message-State: AHQUAubW2hIf/PFtT2B7i/BEC9p4nh7zGC6NcPtqnnAd4ePvsaWkm4ei
	dTnuEfyBCNiJuCsHcKVURJBlDH1YwJhT00X0ztz860Omzzm/AOyVr890YHGVKvIuJHP5UeYCxEq
	1irm04E/2It8DAeM4Ub3c/pEDl33eaGnSte7I8WX5JKGOn2XG7O+I9KUw30TbcXYEJ01KB9kPtp
	AHjF1Z+Vz5val4uQjhhLsKv6JyFopE2yH60QgNw40cNVUYJHVTkpOM6G+p5mp2akX5m5toNG30k
	j+ZwhLYQxLqUAGUY3jCmSlKwAyBvPLyivrhd4Eh6oV9x/w5yd/Saul1zRFq58Nb/D/9qjeQy9Gz
	CCwIu3pREF3AFgg9dcOmWKwYqhMMnlj7g5Ae1hvJJE/0G1wIwr2eUYuIMLKW+wSGjUvW5bTEf0G
	o
X-Received: by 2002:a81:8384:: with SMTP id t126mr26865726ywf.200.1549899559922;
        Mon, 11 Feb 2019 07:39:19 -0800 (PST)
X-Received: by 2002:a81:8384:: with SMTP id t126mr26865686ywf.200.1549899559280;
        Mon, 11 Feb 2019 07:39:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549899559; cv=none;
        d=google.com; s=arc-20160816;
        b=XqYgdKHEpRPH8TV0I7H2GGUv+2CIKxYjIW8dBbGS1EaePqdbvHqy5TNxkBwW8lrFDM
         5rfG4Vzrk2/otfJzn5BxgGphkv6lWDW/Uni7nwuZxO7UdWvH0vMnpHkaRseNC8ZDFluI
         TlrSIIvSw3WQF2X8f2a7IgN+4KhWSX32vNYi85ClkKuhGva0vnyj3AAPD00vrRQ5TFEy
         zzzA391gp1eAeqNmyt/dKe8Z0C0rZCVF4koS/GI8CSX7GKWyvcC3b+ZLRmpqzmYOqOMQ
         8OZs73lqlFCq173wxp8nofitiKrvMlLSuD6T973/bTIVObIaO39RLGAMbJnM1En/GWqp
         BIBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=boQyFNiX0XoZWerTpTg2C8lpdchzW9CQNXvCXi3hMik=;
        b=XGEX9rsnfzpgjGuX0cetcRiSox5KgybbVGHPO40cxb3ZdHJB9k/HyiMBjOb+ZURBEy
         dkc2X+RcGxfZOiTJV9cc4teWz3aQ09p0baJSxVHJAzWlplBAF437Bo+P3Kc0wiZGWUpK
         8Oq4uArOOIKVkxo3sdsFAg6hXutf5hxorMaRHRRvmfsuXJN4UJqn9VAj+blY8UyDmOVN
         taPzG9vy1vt9eiRVmTwR68KNsqlFTW42NAEHMZwWm5YYuugUUHEi126/7NXuf79xcwZw
         UBEnJNyfBINRGQ2MOMS9qewRFoRStvQefgzS6iOS/IqjDsuVrfW1tOurEWoXYm0gU5sd
         HArw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b="Cz7C/op5";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor5027260ybg.36.2019.02.11.07.39.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 07:39:19 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b="Cz7C/op5";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=boQyFNiX0XoZWerTpTg2C8lpdchzW9CQNXvCXi3hMik=;
        b=Cz7C/op581GUNxTLcUjtjsQTNCi0Y3Bp+qn6dcjHeM04i+snxFdxl2Q5t8K3x6nuMG
         MLWGeA7SWY3SxAdEypKir9AeURyWSTDOW0hzPET0xaW0nbw59ZZNfyWG74PGMNHbh/Qi
         XlD9pOhblu5UvvQ1oQ7QNkcpgK5jBb4HzC6FsArd/SoyQKTXh+rxfgitkYrFKaDLelP3
         eCw9ucw79AY/LwZBpNsRSvCvedq6YIo56HtK9c1LOuOiojgeC8VFCbd71JC70o3GU1bI
         qjOcMd7JZACS8h0JahatSh38wSHCIMJT29nry+7AakeP/Qm2uiSMtdZMUTdGQseSWZR+
         RDDA==
X-Google-Smtp-Source: AHgI3IapaQTByQPsAP6IpFkNLAC+n/as07YS8DHCyk5phOCcjXPZW/eoi+XLXwlBlRYx1kQf798QLQ==
X-Received: by 2002:a25:3291:: with SMTP id y139mr26204187yby.79.1549899558746;
        Mon, 11 Feb 2019 07:39:18 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:9135])
        by smtp.gmail.com with ESMTPSA id 11sm4318587ywv.109.2019.02.11.07.39.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 07:39:17 -0800 (PST)
Date: Mon, 11 Feb 2019 10:39:34 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Josef Bacik <josef@toxicpanda.com>,
	Paolo Valente <paolo.valente@linaro.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>, cgroups@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190211153933.p26pu5jmbmisbkos@macbook-pro-91.dhcp.thefacebook.com>
References: <20190209140749.GB1910@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190209140749.GB1910@xps-13>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 09, 2019 at 03:07:49PM +0100, Andrea Righi wrote:
> This is an attempt to mitigate the priority inversion problem of a
> high-priority blkcg issuing a sync() and being forced to wait the
> completion of all the writeback I/O generated by any other low-priority
> blkcg, causing massive latencies to processes that shouldn't be
> I/O-throttled at all.
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
> This topic has been discussed here:
> https://lwn.net/ml/cgroups/20190118103127.325-1-righi.andrea@gmail.com/
> 
> But we didn't come up with any definitive solution.
> 
> This patch is not a definitive solution either, but it's an attempt to
> continue addressing this issue and handling the priority inversion
> problem with sync() in a better way.
> 
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>

Talked with Tejun about this some and we agreed the following is probably the
best way forward

1) Track the submitter of the wb work to the writeback code.
2) Sync() defaults to the root cg, and and it writes all the things as the root
   cg.
3) Add a flag to the cgroups that would make sync()'ers in that group only be
   allowed to write out things that belong to its group.

This way we avoid the priority inversion of having things like systemd or random
logged in user doing sync() and having to wait, and we keep low prio cgroups
from causing big IO storms by syncing out stuff and getting upgraded to root
priority just to avoid the inversion.

Obviously by default we want this flag to be off since its such a big change,
but people/setups really worried about this behavior (Facebook for instance
would likely use this flag) can go ahead and set it and be sure we're getting
good isolation and still avoiding the priority inversion associated with running
sync from a high priority context.  Thanks,

Josef

