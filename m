Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5327C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 07:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E6682184B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 07:21:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tQr1+CHL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E6682184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 324DE6B0005; Fri, 24 May 2019 03:21:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D5F86B0007; Fri, 24 May 2019 03:21:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19F4A6B0008; Fri, 24 May 2019 03:21:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D49086B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 03:21:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r75so6219740pfc.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 00:21:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fv5+nm9pyA3wW2Yn2fm+/s4r+RxIRtXfbrcB1oGclRQ=;
        b=R2TEaUn/3qoyhtOKI91C4N2M8YbQIoGq7cXEpa4u3qC9lNOC37mxXWSWxORin6fniY
         fysJaECelcY4a/H+N8FrnutsNr4ajJaz7cWeLlxXXRizmMtkyKoFpG6HqqRvBNsYg8TO
         pGG7rBTXV2oAQA1jNbqbaphzG1iXO72g5MSafZxHmKQZXHZybEXXe29wcrWgMfL01Jt8
         buKUD8fHNolIdWflwnbv74hng0QihDT9zlKHPhBc3Yq8YnYKaFOJ06YnvhQaDUt6dgYx
         2zpPsGy3U+ZJU9j9EQo5oU298E683fKH+YFDzDmrTLRlkV9NRfgmw64BYm4P2kIY50UE
         BLSg==
X-Gm-Message-State: APjAAAU5BfsZ+g4YTx5iZRQ3Gjid9eWvxDbzwR4dM42g7TjpuXkG7wW7
	VkL0IklryUHQdhwdWBJ5tFH8cn6NUIcsXmS6abk34lxZyshAYg9TXXPZq+7XOzGcIjIXutOuILU
	LnI/bOd8Hy2YZPYvI2zRDSH0U+u0XXBB0SZdva2/olezxZ4BlgOKT9uLkOOyLhkI=
X-Received: by 2002:a17:902:3343:: with SMTP id a61mr1522657plc.274.1558682512408;
        Fri, 24 May 2019 00:21:52 -0700 (PDT)
X-Received: by 2002:a17:902:3343:: with SMTP id a61mr1522597plc.274.1558682511208;
        Fri, 24 May 2019 00:21:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558682511; cv=none;
        d=google.com; s=arc-20160816;
        b=p7TogafvcfvWPMqQ/QB8CPrYQWA3WeuenjLM8Wyy9rGS1uYiPKjvk2WjPUNUiJ69U6
         vUzDg2CZ1Mo+UKuGHSHfnJRCWoXCfT1WfkU8myiSwEQwdGGFmbmChEUP7hWrhU8ZViBi
         5fhTTQ9XrHWhltOkrQk215r+km4ufMLAOPyknwwUAJ+O/r2F3nYeUswIEtUp7IFm+dfs
         V+VT6X2tA6WHlU8hQOKNoe+Y+effOrDi2chyuCejynRBq5CQi5UDOltb3IscWhO51SfK
         kNlScj+PAjiHVQYYRX5FA5qvidPmGMA2yEPylBPkuB4BE0qMMwLJBpSnw6ldodASIChB
         CSig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=fv5+nm9pyA3wW2Yn2fm+/s4r+RxIRtXfbrcB1oGclRQ=;
        b=lwMsy8B1tmUdLvF+opHoQU9uY+yQ/1Gdb+8YeITJnYwylhnvnbBOgpIJ+Doued+wH+
         3i+2SAb3xb2Yy2MZq4uGnBWtyU+iPol2EPv5+64ZW+7qazGvTN/E/6HRMYuyUEuqg5T0
         D+1uwUyXBW3SMJNcNctoI9wXMm5JTLoLvWUi5BPLXXZfM6SCY1u5bHGu9a0P1ZDrywuV
         F+MQNbaUlepXFvF9IuI3TPJtvObV3jgoQrjOPdTNCw++oyDg2g405/Blo63YpcYvtxzd
         g6dgLZHJtoa4HGd8vrtFVKrXC3L0IFn0OskD8eMuS0y863QlO/v76Lvqq6KAQuKMm4XA
         givw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tQr1+CHL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor1823481pgi.62.2019.05.24.00.21.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 00:21:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tQr1+CHL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fv5+nm9pyA3wW2Yn2fm+/s4r+RxIRtXfbrcB1oGclRQ=;
        b=tQr1+CHLhSxOLxdBf9R6McAd4uQ8rZ1Ua9L6BOM1JAc+hT9gadNjbMJU8W5GgEu+LC
         z6D5XBMOTqpJDXA3TZ/I88MEtXEZ6FpTiUqQRR8ZWUseyiZReAlaYFFVOLju++gBI+o0
         3FzExXa+quM5A7W796fNKHMqI6BK+7ZwY6L6SQDOY+fnPzt4Pu4aFMypL2Mh9IuLSxZU
         rLiFkMRHRcRRoaZsQH3jcdScdW/2qB211cCoqM4hXZDcC+eSE22goJnAUBcbUaiAZBtZ
         xH++SEVfTGL23WCcBSWWZXe+1I90TIympdPo14YFspEhiy8AOOqQzUr95LGsaLoan15i
         /5xg==
X-Google-Smtp-Source: APXvYqwTvdGDLS5BHxN58x5vGKEyCb4Q5CzWRoI9yTEqRDPGj3r1pmOuxVt4F2S+eHLXZ/nB2IOLaw==
X-Received: by 2002:a63:1d05:: with SMTP id d5mr102496701pgd.157.1558682510773;
        Fri, 24 May 2019 00:21:50 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n27sm3036263pfb.129.2019.05.24.00.21.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 24 May 2019 00:21:49 -0700 (PDT)
Date: Fri, 24 May 2019 16:21:45 +0900
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@kernel.org,
	Wu Fangsuo <fangsuowu@asrmicro.com>
Subject: Re: [PATCH] mm: fix trying to reclaim unevicable LRU page
Message-ID: <20190524072145.GA106222@google.com>
References: <20190524071114.74202-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524071114.74202-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 04:11:14PM +0900, Minchan Kim wrote:
> There was below bugreport from Wu Fangsuo.
> 
> 7200 [  680.491097] c4 7125 (syz-executor) page:ffffffbf02f33b40 count:86 mapcount:84 mapping:ffffffc08fa7a810 index:0x24
> 7201 [  680.531186] c4 7125 (syz-executor) flags: 0x19040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
> 7202 [  680.544987] c0 7125 (syz-executor) raw: 000000000019040c ffffffc08fa7a810 0000000000000024 0000005600000053
> 7203 [  680.556162] c0 7125 (syz-executor) raw: ffffffc009b05b20 ffffffc009b05b20 0000000000000000 ffffffc09bf3ee80
> 7204 [  680.566860] c0 7125 (syz-executor) page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page))
> 7205 [  680.578038] c0 7125 (syz-executor) page->mem_cgroup:ffffffc09bf3ee80
> 7206 [  680.585467] c0 7125 (syz-executor) ------------[ cut here ]------------
> 7207 [  680.592466] c0 7125 (syz-executor) kernel BUG at /home/build/farmland/adroid9.0/kernel/linux/mm/vmscan.c:1350!
> 7223 [  680.603663] c0 7125 (syz-executor) Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> 7224 [  680.611436] c0 7125 (syz-executor) Modules linked in:
> 7225 [  680.616769] c0 7125 (syz-executor) CPU: 0 PID: 7125 Comm: syz-executor Tainted: G S              4.14.81 #3
> 7226 [  680.626826] c0 7125 (syz-executor) Hardware name: ASR AQUILAC EVB (DT)
> 7227 [  680.633623] c0 7125 (syz-executor) task: ffffffc00a54cd00 task.stack: ffffffc009b00000
> 7228 [  680.641917] c0 7125 (syz-executor) PC is at shrink_page_list+0x1998/0x3240
> 7229 [  680.649144] c0 7125 (syz-executor) LR is at shrink_page_list+0x1998/0x3240
> 7230 [  680.656303] c0 7125 (syz-executor) pc : [<ffffff90083a2158>] lr : [<ffffff90083a2158>] pstate: 60400045
> 7231 [  680.666086] c0 7125 (syz-executor) sp : ffffffc009b05940
> ..
> 7342 [  681.671308] c0 7125 (syz-executor) [<ffffff90083a2158>] shrink_page_list+0x1998/0x3240
> 7343 [  681.679567] c0 7125 (syz-executor) [<ffffff90083a3dc0>] reclaim_clean_pages_from_list+0x3c0/0x4f0
> 7344 [  681.688793] c0 7125 (syz-executor) [<ffffff900837ed64>] alloc_contig_range+0x3bc/0x650
> 7347 [  681.717421] c0 7125 (syz-executor) [<ffffff90084925cc>] cma_alloc+0x214/0x668
> 7348 [  681.724892] c0 7125 (syz-executor) [<ffffff90091e4d78>] ion_cma_allocate+0x98/0x1d8
> 7349 [  681.732872] c0 7125 (syz-executor) [<ffffff90091e0b20>] ion_alloc+0x200/0x7e0
> 7350 [  681.740302] c0 7125 (syz-executor) [<ffffff90091e154c>] ion_ioctl+0x18c/0x378
> 7351 [  681.747738] c0 7125 (syz-executor) [<ffffff90084c6824>] do_vfs_ioctl+0x17c/0x1780
> 7352 [  681.755514] c0 7125 (syz-executor) [<ffffff90084c7ed4>] SyS_ioctl+0xac/0xc0
> 
> Wu found it's due to [1]. Before that, unevictable page goes to cull_mlocked
> routine so that it couldn't reach the VM_BUG_ON_PAGE line.
> 
> To fix the issue, this patch filter out unevictable LRU pages
> from the reclaim_clean_pages_from_list in CMA.
> 
> [1] ad6b67041a45, mm: remove SWAP_MLOCK in ttu
> 
> Cc: <stable@kernel.org>	[4.12+]
> Reported-debugged-by: Wu Fangsuo <fangsuowu@asrmicro.com>
Tested-by: Wu Fangsuo <fangsuowu@asrmicro.com>

I forgot to add his Tested-by. Sorry about that.

