Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA594C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:40:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C4B2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:40:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c8Dpw+3t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C4B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 407DF8E015A; Mon, 11 Feb 2019 15:40:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B7988E0155; Mon, 11 Feb 2019 15:40:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A8188E015A; Mon, 11 Feb 2019 15:40:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C74658E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:40:32 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y85so57869wmc.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:40:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aRRtjcrcVo+Gfaj/zX8Bw1iJ3MLE2kmxEDTa4rlrB10=;
        b=qaD1ZPb69J3LlRZvKLJ4qgzy8tHbXc5kQ4G5Qfq1Ym50lST35QuuLWj20AMjz56If7
         8evetL1NbRGyavzQFA3JUlitY8g2+yCE6Ora8xtgCo+c6R2nsf5ruxxhd0hcDfvlww0/
         lUeLSRqUc5ePoSZdhk3SqibmI1YWA5kP2X+vWStxK0jd6TV53z5h+3O5/RBAKkv3dRYd
         kPzMhQdN994ykpFnpbG8w845FG0J4NPO2fmvAbjECDPL30ORPT1hJHrgCy1gwpLcpd9j
         r6ZS025KMhTNE7FUw4cB8mTdiW6ImBgaU9XMAjuTvGJvk23QfI0daQnVo0NcqqtKzNqE
         NwFQ==
X-Gm-Message-State: AHQUAubDfy4cUhvMvbbXYCS/Lm1oWMrabot6iXILxiaoQBx+sojSXEy/
	PpDeEx7nrG4LJ85+P6YcgalTd0lh2an1FwJ6bpVHssaDSGvkfakWDqS3ONaUJdaAltbaTJ4Qt2r
	qEAS3rXTjLo/RrG6cj/6pzg6Sk78eUjJ3lMxWKayNpzxA41xUXWNcGzB3Kfyz9xjVqTwB9Pf/oQ
	7UcR+l4NHmHTvcDUEK7gKwSs1vNV4U1CiaRYBwkcjQmpxAkEIbtbRLrCCXt9cbspR7UcLYcuUie
	01wl390nyZfx2R45yhvq+zNK1T+lmbhG65xXA3iC3VnxzafmQuqEU4q6YiTXYYb7IOxGd8X8Giz
	uMTlc/YkwyahfeWBzH7asF7Kr//uVJbPoUnJ7tkekCERl5UiQZnbvKjG8XVONaGkTKnIq5fcul9
	I
X-Received: by 2002:a1c:14:: with SMTP id 20mr49967wma.91.1549917632352;
        Mon, 11 Feb 2019 12:40:32 -0800 (PST)
X-Received: by 2002:a1c:14:: with SMTP id 20mr49920wma.91.1549917631357;
        Mon, 11 Feb 2019 12:40:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917631; cv=none;
        d=google.com; s=arc-20160816;
        b=pTVGhUzx3FGTso5qm9pcT83y0gKVXoZwNTkjJlM1OPy4efXVsZbtrrgMvaDUAVDvXW
         k4XmlhJdQ8gDFOhGfxJ/9F4qGRLtTeKoMhhfr8pTn8LAn5mfXc0gRBGrUpyLyuY10RzD
         0aoTrBZoWte/QMccbnS0aJVMN16yjBDZGPs8QbbFYYAzqPtUuGz8m3jJz5GrvtNFI88h
         Ev4PFMlGvFSjPoMhfZrHtAjge8TaDZt88HnVdhNQD2Ybpo/dnZmaAevMHwE6O6b4HMtJ
         +ToLoxYSK9+cuObglaKzBhGkCLX/J7HXIT/L6bcj53hhw23aDWe7Mt5m1L1da8KbOT+q
         +8YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aRRtjcrcVo+Gfaj/zX8Bw1iJ3MLE2kmxEDTa4rlrB10=;
        b=mTdCqJh7cLVjSD8zLLiHxcJBtDdP5OdAnODX5o5cac8HMoZ6GwBYVESczIEvjjPj/i
         YRGEKiEmpKwMkguTDEMMAaai2ubEL0XPyetfqootrqqVlpB81+fKUi3FlrukhJzp2qhJ
         kIibwZPExsWV3/Si5BubbRyRJ5AGBC8VCTrpAkRIvOpNoAmdI6KWkDS179XRF3Ub47EK
         PiO8QuwFwSX6yPRwEitoeIea+7Vsq9lb7yY3lAZf3alwPif7FdrFzEqf+3HKscLLaYOC
         mzashmH+mvlPjj+53rZdj9oAAMr6+GdaVx0KDu9dTv/isCgB4d96ff4avgL/PPDIecyO
         20+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c8Dpw+3t;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor6870954wrh.6.2019.02.11.12.40.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:40:31 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c8Dpw+3t;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aRRtjcrcVo+Gfaj/zX8Bw1iJ3MLE2kmxEDTa4rlrB10=;
        b=c8Dpw+3tPDH4dqPl8avgxjKxKfbxB7sXLA1eCltNVPmOgXV49okHrFlPpvJiBkUJOU
         CVYJyM/WWWE95z+5t1CscflAI3ljDt7nltAPQlUSDZIFc5t/AWddrIWKXEM9hH27Kdjq
         jdjkv7NcUJmEqxDJCg8LtVbyj7seo/r96FOuqwMvPlCY3RoyuPX6htWxj1KYM14PDxTy
         mSZhMDVKDx8rIFLr+GnLXOsSJSvGRfJpiPZHRLyuOdwsslNOI2fR3CcyBkhnwxNhvUNA
         2xLzXdhYPWsMcKwxYMl5P9Aub8MGdL9ZtQ7d334VMYiJgAqT3/4Rrumi2lxnQpiwtU+E
         oGQA==
X-Google-Smtp-Source: AHgI3IY5TG3Z9EP68R9xnD7caOTWZlOc+FwnEu9lJPOMZgKlSDNrTR1qwhbn4mTnEhZftd2y09+ejQ==
X-Received: by 2002:adf:ee82:: with SMTP id b2mr57625wro.185.1549917630648;
        Mon, 11 Feb 2019 12:40:30 -0800 (PST)
Received: from localhost ([95.238.120.247])
        by smtp.gmail.com with ESMTPSA id e4sm10742811wrt.53.2019.02.11.12.40.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 12:40:30 -0800 (PST)
Date: Mon, 11 Feb 2019 21:40:29 +0100
From: Andrea Righi <righi.andrea@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Paolo Valente <paolo.valente@linaro.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>, cgroups@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190211204029.GB1520@xps-13>
References: <20190209140749.GB1910@xps-13>
 <20190211153933.p26pu5jmbmisbkos@macbook-pro-91.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211153933.p26pu5jmbmisbkos@macbook-pro-91.dhcp.thefacebook.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:39:34AM -0500, Josef Bacik wrote:
> On Sat, Feb 09, 2019 at 03:07:49PM +0100, Andrea Righi wrote:
> > This is an attempt to mitigate the priority inversion problem of a
> > high-priority blkcg issuing a sync() and being forced to wait the
> > completion of all the writeback I/O generated by any other low-priority
> > blkcg, causing massive latencies to processes that shouldn't be
> > I/O-throttled at all.
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
> > This topic has been discussed here:
> > https://lwn.net/ml/cgroups/20190118103127.325-1-righi.andrea@gmail.com/
> > 
> > But we didn't come up with any definitive solution.
> > 
> > This patch is not a definitive solution either, but it's an attempt to
> > continue addressing this issue and handling the priority inversion
> > problem with sync() in a better way.
> > 
> > Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> 
> Talked with Tejun about this some and we agreed the following is probably the
> best way forward

First of all thanks for the update!

> 
> 1) Track the submitter of the wb work to the writeback code.

Are we going to track the cgroup that originated the dirty pages (or
maybe dirty inodes) or do you have any idea in particular?

> 2) Sync() defaults to the root cg, and and it writes all the things as the root
>    cg.

OK.

> 3) Add a flag to the cgroups that would make sync()'ers in that group only be
>    allowed to write out things that belong to its group.

So, IIUC, when this flag is enabled a cgroup that is doing sync() would
trigger the writeback of the pages that belong to that cgroup only and
it waits only for these pages to be sync-ed, right? In this case
writeback can still go at cgroup's speed.

Instead when the flag is disabled, sync() would trigger writeback I/O
globally, as usual, and it goes at full speed (root cgroup's speed).

Am I understanding correctly?

> 
> This way we avoid the priority inversion of having things like systemd or random
> logged in user doing sync() and having to wait, and we keep low prio cgroups
> from causing big IO storms by syncing out stuff and getting upgraded to root
> priority just to avoid the inversion.
> 
> Obviously by default we want this flag to be off since its such a big change,
> but people/setups really worried about this behavior (Facebook for instance
> would likely use this flag) can go ahead and set it and be sure we're getting
> good isolation and still avoiding the priority inversion associated with running
> sync from a high priority context.  Thanks,
> 
> Josef

Thanks,
-Andrea

