Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D43EC43612
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 08:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC0D0217F4
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 08:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KQxOTJug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC0D0217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43E398E013C; Sun,  6 Jan 2019 03:42:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EBBE8E00F9; Sun,  6 Jan 2019 03:42:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC088E013C; Sun,  6 Jan 2019 03:42:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF4688E00F9
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 03:42:08 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id y16so15743814ybk.2
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 00:42:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=N57xE6X60kc1vPkUyv21EpTcZH2YwZpb2Eb7+F4WVoM=;
        b=ZOGJFufo8bGFAHF42zKM3qxhleLYCsMxM+oCa1UomdmKde4fbcJqFTaCuaY8dv1I5f
         rifF2KPu3GARrq9msgzAa+WYjZzVLwu/SSOTidnN7sFLXEx1NBWQaamyLSBr7hw1C6Pw
         iwKyi4iHhVeaToBcfWWbWAcqh/0C8AXyMrB9gLyRWhfk+FHS5Nn7TvQwWCt/KUypv47E
         mf+SCbxn6YVhLb2mA0490z5kRzHC67aMrfnSmS60D3O1jx4mqpk+4BA3RysC9Mvy/zyM
         D30cosr1SmfDFpuDYGudBodnJOCS8HEjWQHV0iduYVJxvuylH06w2fepSg0Mi1hk/f1y
         eyTQ==
X-Gm-Message-State: AJcUuketvMSCTtGqFnbHAS+hzfsHLjqwpJH/hpSAPrZPY9+v5VNmO8aF
	yLff4pLSeh2+YTcmJDfCssbNZcLPAtoMPtS8xocvPczIwCpI8kGvDSPL3uC9JkVIndlx0ZKNWkT
	3JI1ewR/O6IIujdoFR0OgRUnO4qeV8YwySD7qmvbGyEURc0MF0OnTQEDC3HCRCPInog==
X-Received: by 2002:a25:e056:: with SMTP id x83mr56322506ybg.183.1546764128511;
        Sun, 06 Jan 2019 00:42:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN41rekRWBZbosGxlgEGycNWk/+DeIi8hTJR+jxE0nkmV0F5kfAvFgtQ07l+QyuX/kKhIykT
X-Received: by 2002:a25:e056:: with SMTP id x83mr56322480ybg.183.1546764127846;
        Sun, 06 Jan 2019 00:42:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546764127; cv=none;
        d=google.com; s=arc-20160816;
        b=GspcqzR7zIqobkAagvFAfcj97cznAPuXq+0jLbMI3JHWtoSoV8uZP3N7wH+MmmKroe
         IjRP4FaMT1bwFKPICWUa5nbwjYk7VYeEmiyBJOvIUzJgmP0REpbMSI13pp/dphZcqG+v
         2MsPn7DNZ+rOKKt6HK+kwSrWhzskJ3zbo61tHR2diweXSz9ZGGfTewqUBfb0vAB/x675
         CZKAGZKfh/3uHMClWA/EFeBpndSQpqOe53DorTrbDG8wmsCFx9FHL10kvlskPZ4Emj9z
         HZ3ly7PgfjQ805tu6RDsHXE5Wtr2LvgcJaZrjtXYVTlUf2FWp4En8YHW09CXY6IXQqqR
         kGyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=N57xE6X60kc1vPkUyv21EpTcZH2YwZpb2Eb7+F4WVoM=;
        b=wgwyuX6N4gedro4CRzlX2AoeuLhYcXYWi1c959/cCvgCsDnliCyZgDu07qz9l+nMsa
         /OotOVgbG1yiY6/3iYd0dUmtBN+h61vIBN2xXKcs+mvJcT0x6HvDsC5Hn7jgP+Z2ZojC
         XV+8A/0nLmZvO7S5sJX+R0W/36F+GoeywIgrAvkwjABgUKCeuUr1zlpSbRYHpAN76jX/
         TkppIEIf0k375H4OYu02wvXLH3HFnXg6Q8um7eVrVGvm0OOwaR5Cbb1uzMnmSPBOKJLp
         4drBdZmxGLjoV7NVYtQB8K2sgRquwJOrDs89PLhLgeVgzWTsf1a6+rLGdgvINdimqxS8
         H44g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KQxOTJug;
       spf=pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=amhetre@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id u9si17046100ybm.25.2019.01.06.00.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 00:42:07 -0800 (PST)
Received-SPF: pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KQxOTJug;
       spf=pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=amhetre@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c31bf480000>; Sun, 06 Jan 2019 00:41:44 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 06 Jan 2019 00:42:06 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 06 Jan 2019 00:42:06 -0800
Received: from [10.24.229.42] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Sun, 6 Jan
 2019 08:42:03 +0000
Subject: Re: [PATCH] mm: Expose lazy vfree pages to control via sysctl
To: Matthew Wilcox <willy@infradead.org>
CC: <vdumpa@nvidia.com>, <mcgrof@kernel.org>, <keescook@chromium.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-tegra@vger.kernel.org>, <Snikam@nvidia.com>, <avanbrunt@nvidia.com>
References: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
 <20190104180332.GV6310@bombadil.infradead.org>
From: Ashish Mhetre <amhetre@nvidia.com>
Message-ID: <a7bb656a-c815-09a4-69fc-bb9e7427cfa6@nvidia.com>
Date: Sun, 6 Jan 2019 14:12:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190104180332.GV6310@bombadil.infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"; format="flowed"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1546764104; bh=N57xE6X60kc1vPkUyv21EpTcZH2YwZpb2Eb7+F4WVoM=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=KQxOTJugnLHQ/dfCYrJYOCZouVtBXuRn37rGh3xe2d8wYNZjJh9IHQGBzm9ZtgSl1
	 zeit6GG3RL7oJSmILsW7CKita4WZ8GdEcfBSp4/6zbBQnsb+f2fNn8tdK7ci1axiCz
	 1hc3gpVyZyG7b6sn6VjwgwJmAT3VQ0H+emmnrIszbw98kPN3es94K0BuLxIDMjq3ZN
	 mVFJhodCG9+nnZyxGiydLA++rcxsy96PBWB1Lx0Oad9S+yMEsHmdyep5Ra5N0dyWl3
	 48ff0nZuHZuKEVixdP00kroxjgY77ayjE207kgyK6LQo9SuTbRaTwlJ6TfFsqoeD4R
	 cqj4mHfFoSzcA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106084202.beTBJ8LI3kG5yOwD2IHeLi2jD7TG6m-ipfpHYFtuCY8@z>

Matthew, this issue was last reported in September 2018 on K4.9.
I verified that the optimization patches mentioned by you were not 
present in our downstream kernel when we faced the issue. I will check 
whether issue still persist on new kernel with all these patches and 
come back.

On 04/01/19 11:33 PM, Matthew Wilcox wrote:
> On Fri, Jan 04, 2019 at 09:05:41PM +0530, Ashish Mhetre wrote:
>> From: Hiroshi Doyu <hdoyu@nvidia.com>
>>
>> The purpose of lazy_max_pages is to gather virtual address space till it
>> reaches the lazy_max_pages limit and then purge with a TLB flush and hence
>> reduce the number of global TLB flushes.
>> The default value of lazy_max_pages with one CPU is 32MB and with 4 CPUs it
>> is 96MB i.e. for 4 cores, 96MB of vmalloc space will be gathered before it
>> is purged with a TLB flush.
>> This feature has shown random latency issues. For example, we have seen
>> that the kernel thread for some camera application spent 30ms in
>> __purge_vmap_area_lazy() with 4 CPUs.
> 
> You're not the first to report something like this.  Looking through the
> kernel logs, I see:
> 
> commit 763b218ddfaf56761c19923beb7e16656f66ec62
> Author: Joel Fernandes <joelaf@google.com>
> Date:   Mon Dec 12 16:44:26 2016 -0800
> 
>      mm: add preempt points into __purge_vmap_area_lazy()
> 
> commit f9e09977671b618aeb25ddc0d4c9a84d5b5cde9d
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Mon Dec 12 16:44:23 2016 -0800
> 
>      mm: turn vmap_purge_lock into a mutex
> 
> commit 80c4bd7a5e4368b680e0aeb57050a1b06eb573d8
> Author: Chris Wilson <chris@chris-wilson.co.uk>
> Date:   Fri May 20 16:57:38 2016 -0700
> 
>      mm/vmalloc: keep a separate lazy-free list
> 
> So the first thing I want to do is to confirm that you see this problem
> on a modern kernel.  We've had trouble with NVidia before reporting
> historical problems as if they were new.
> 

