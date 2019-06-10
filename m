Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1E12C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 09:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CA622082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 09:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DCWBITwF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CA622082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 293C56B026C; Mon, 10 Jun 2019 05:42:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 244676B026D; Mon, 10 Jun 2019 05:42:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10C956B026E; Mon, 10 Jun 2019 05:42:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE6536B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 05:42:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so6586474pgs.13
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 02:42:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fmMoFhGab8QQq+4ZFOGVd3lIsa5ObNxIXJORVfF0Hlw=;
        b=rty0CB4rtN+TuqaiRU4JnM1t+YfaSYAcxxtRqSE6ETZ5H2JvvoFvHL85h5x6ilRpOu
         7D5n6KlIGmipMNZHYFNIrQC5MFpUla7+NG9BsVrrZ7mw2+R5c5hRSMQUlHgyVYhWzgT7
         509Lr4zFF1+Zv6//q3ON8BpTkTVGwHVZBTO0OrtEiD2CNslNVK2uTGqCYuWdKjHBUOBH
         uAEMGyhuBCdHeNC/O4XqyLxAVBCfmhO5txiuSz/L2XTwyj3OgCvjawDy1AOudNcLiXUM
         89O5XTwmU6I/ft6vjFttEsPY4fNxybMyIeqDvXNNeZ/a174sR5pGoSjUS9JoCFqai8EL
         kGAw==
X-Gm-Message-State: APjAAAW4RqSju5nQeIXyt7gyjP9jkmaQuY1nq4f3VaU7PuCooRa84Hyc
	LUaLQfGxxq78JZqDzuUHv1B8qMmKcv8f4tuvkp65N0tARrbrjN1ufiMBZhAWQuE2psz+18dtCEQ
	2SBX1zeyB+Qz2r4PGgvwp2qBzbHOjTMLO9fUpeajsAJeUhFLSln9yz9B8B94qsCI=
X-Received: by 2002:a63:4c1f:: with SMTP id z31mr15359388pga.334.1560159750271;
        Mon, 10 Jun 2019 02:42:30 -0700 (PDT)
X-Received: by 2002:a63:4c1f:: with SMTP id z31mr15359303pga.334.1560159748563;
        Mon, 10 Jun 2019 02:42:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560159748; cv=none;
        d=google.com; s=arc-20160816;
        b=rFYmVztv+t5slc53Ef3H444KL0mYehFyzpo/FBKe35PT0UH6EY+ZZNLjFuHt6wyS2O
         TjK8OY8i6RibMr2STfOAxGfI3ZpnbVVdXPs9mx5gL18YRd3t5KmwE7nulqp5c+r5AYe5
         0YR1/W/xg9inFBDWVK7vXaraTYSDDGpIrfEgPaIgpuS1kOuz8IigtjJus2VFRvAviC12
         IYaHDAAcU89oxJsgspvz9Gn93mMh5n/smNHhvqLbvrWCfrg1qV32dEmBFI1p12xRqMyq
         yp9bzJK3bVCPCFfVuvM2G4i3T3Xu8N1kUY6svcMb7g8q+O8KDbaoR7i+kTBor8w4gQR6
         vpYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=fmMoFhGab8QQq+4ZFOGVd3lIsa5ObNxIXJORVfF0Hlw=;
        b=IXmPWKGdzqYVZhfRUrK9YfA7DECexNdJpuBP8NAtSPH0nBd9L45ekfmRsQr73+Et7b
         tFAsLu7JCAwxZyiN5eWPw2Z8aEHmXg6xl5cLMHFvz4c0q5QFLpNh4zrn+F02qWlHwMWb
         rZq2ZTwWbYeTd4OAd//wqJYrrpGhVDqN+Iya+AQh78WpeA71Kk8NobCenW4P8DJXdwo8
         8Y5drKD5EJcY36cQS1kHdY8p0cIpq+PfxGN8CGFFnnpXHHnzW3HtUBg8yH/waLqbgoQ1
         STtBZDiOybC1+IEQFTf++32orfs+TdKmquQClPxTTRICjAXWPtuAVYI8KzefvrbtRUR1
         uKbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DCWBITwF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 194sor8631475pgc.19.2019.06.10.02.42.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 02:42:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DCWBITwF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fmMoFhGab8QQq+4ZFOGVd3lIsa5ObNxIXJORVfF0Hlw=;
        b=DCWBITwFEZ/nZZHhoQiGgSKqY+Bg+p9DQpXFEzfeQPUR1owHIM6Jzu8KtMzqTp4JLd
         SKNqnMWYYWBEmOYQaxgRpBF5krcBW5Lj7c/9g9SuNPHO9OFjMIrLYg8DJxdKeUciotSA
         BcoCmu930A+/EJQAwoDqicVpodwgUviIWX3jKAcqtimR8jzCYQ2eUncu8G41rLOIjxdh
         FZN4PhQNXYhuR9BaBpIY3lAytW8/PQiL8OplKLVIXHV2STSeVKw2VLz3oCKD2djfMVCy
         BSlVkKTQeKwFFyevpLCzJsdcJPlFzYs8QK8tV14/amM0DZlPvcghTnnXSPJkFlqZReBj
         sRZw==
X-Google-Smtp-Source: APXvYqzLJdBS8O+tcgX/72R0zigsfon0cIQCkAY11GgyKWuOMosGl04CXHAjfRMr4sraVck30xrnnQ==
X-Received: by 2002:a65:5302:: with SMTP id m2mr14789887pgq.369.1560159747932;
        Mon, 10 Jun 2019 02:42:27 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id g71sm14625294pgc.41.2019.06.10.02.42.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 02:42:26 -0700 (PDT)
Date: Mon, 10 Jun 2019 18:42:22 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	stable@kernel.org, Wu Fangsuo <fangsuowu@asrmicro.com>,
	Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190610094222.GA55602@google.com>
References: <20190524071114.74202-1-minchan@kernel.org>
 <20190528151407.GE1658@dhcp22.suse.cz>
 <20190530024229.GF229459@google.com>
 <20190604122806.GH4669@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604122806.GH4669@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 02:28:06PM +0200, Michal Hocko wrote:
> On Thu 30-05-19 11:42:29, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 05:14:07PM +0200, Michal Hocko wrote:
> > > [Cc Pankaj Suryawanshi who has reported a similar problem
> > > http://lkml.kernel.org/r/SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com]
> > > 
> > > On Fri 24-05-19 16:11:14, Minchan Kim wrote:
> > > > There was below bugreport from Wu Fangsuo.
> > > > 
> > > > 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> > > > 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> > > > 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> > > > 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> > > > 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> > > > 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> > > > 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> > > > 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> > > > 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> > > > 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> > > > 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> > > > 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> > > > 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> > > > 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> > > > 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> > > > 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> > > > 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> > > > ..
> > > > 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> > > > 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> > > > 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> > > > 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> > > > 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> > > > 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> > > > 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> > > > 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> > > > 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> > > > 
> > > > Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> > > > routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> > > > 
> > > > To fix the issue, this patch filter out unevictable LRU pages
> > > > from the reclaim_clean_pages_from_list in CMA.
> > > 
> > > The changelog is rather modest on details and I have to confess I have
> > > little bit hard time to understand it. E.g. why do not we need to handle
> > > the regular reclaim path?
> > 
> > No need to pass unevictable pages into regular reclaim patch if we are
> > able to know in advance.
> 
> I am sorry to be dense here. So what is the difference in the CMA path?
> Am I right that the pfn walk (CMA) rather than LRU isolation (reclaim)
> is the key differentiator?

Yes.
We could isolate unevictable LRU pages from the pfn waker to migrate and
could discard clean file-backed pages to reduce migration latency in CMA
path.

