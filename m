Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AED54C04AB2
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F83C2182B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l+ARRXQv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F83C2182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0363F6B0003; Thu,  9 May 2019 18:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F29476B0006; Thu,  9 May 2019 18:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18566B0007; Thu,  9 May 2019 18:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABF8C6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 18:54:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s8so2661216pgk.0
        for <linux-mm@kvack.org>; Thu, 09 May 2019 15:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JvTTJlUXvU8XNTu6IHq/kWa6Qzp6vsqlnkM/sU+WpRo=;
        b=bLxYTN5uT+skNmvJqhIcUU0SS8LSScGHuPISKzD5TK5QB1B1u1OXSVkjjadObMp3fr
         k15vdZnh1jPOk9TjkP7J0zyrHHm8RnJdPFUMoCk0v+542LONUWWnRg2umhvl7CTQaZOF
         +hlZfCWKEyE+7+E30M/VIXkLMXlkZ5DglXY9dJEHOofTRS+Dd5PzB4H/Zk42GUjfMfmN
         hGEQEHvFd4+BvYhS+ZpTHNrc5Ak58MIeHzbkxiojz89RMizqt66BrAY0ujEDwybeSndY
         2tR8e2JgqyO2RgQ53OkvFx53SEzO712iA6OW4UW8tHBPdt41SKcth/Zi9Y9z8Cf6OExm
         5lag==
X-Gm-Message-State: APjAAAVUqFu+PgjcUVqzSb9g5EnTbeARHyCwplN+XXojoYbmZnwQlHOZ
	hpM468v7q2i+dVtMAUu/mG5tfIRS58fqtkyjtIZXRVY1I/U+9phOllG+SZTGlbn9j/V8Np4mA50
	6AsJqUpsutO8X7Or5Jqq1K5jT1VqLb0FqA5MuT2TSfXIgbDJxFDvLCLpQNM72SIkDFw==
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr9176865pgh.391.1557442492243;
        Thu, 09 May 2019 15:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOEshamzfd3f0bCzUrjTDh+S8t2Pc1CLG6dJLmGM4QvXThElisqEJRI7k6tRcmeulkvLyo
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr9176775pgh.391.1557442491243;
        Thu, 09 May 2019 15:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557442491; cv=none;
        d=google.com; s=arc-20160816;
        b=O9DD+GNgvJ9VuO2gsk8jyt4/eQvLUd4iVK+jLrXaJkVzs4jGE2PsQhwX6KLmn9l/Sy
         Bv4b5gjvkp8CjUQKwzXqDocUEaCuY4/EzIl0CjXcZFT9CrLiE3yxpRMfAFh7OR44urPc
         KegCbS4AkJbQgyOhhxV5ND9EDYiercb+275VbsJRGqKDEHEdwpSYlFbwx3HBh2swk6BW
         Q2VzZlP2zx4B6snwmAycHVcOIYHIXdHy/s8/uVOvux4MB59R9/UzLbDDvAAQWmtbuILE
         yIGikFCWJRQREpdA/i05GWMRA0t4e9qnN0elH7tHMfGqrFmjtRq9KeyURbvLcTmy6HrT
         HoaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JvTTJlUXvU8XNTu6IHq/kWa6Qzp6vsqlnkM/sU+WpRo=;
        b=Wr4VAhidZpSkyVdzRvFC2HpJpChx2No9HMsXItS5I3eWIUZOu3ZRdCwcuo5360ddLq
         KBPOJKcNKVMW2L0DFxNGvpNV0wczwqFM3k19p+SJGG7a6SR9BqHzjJEZIylNJyF6b5jp
         SDxS6NMGsJX+MQdEuSZLUPWchjzWjRPk0xjF0Q6czigbXueLWjLttYOwoXwL5tKIULpa
         GZG4MMktBgrDxo4Ik216LUvmbjOPjPqikHgW+DybbeEvednoo7FXKNKorwz1xgZmzGi5
         wFu5Rv/VHoUajz7QVlYP4CiSJbUdiBk56NVDHY8FlnHcfluQTt4I5xparLLUAQDtRvcm
         97BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l+ARRXQv;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id gn14si4493701plb.7.2019.05.09.15.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 15:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l+ARRXQv;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3AF6C2177B;
	Thu,  9 May 2019 22:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557442490;
	bh=MslwbGMGtefXAWdqoRks6S7doMHcsjJBefOUECVcWrg=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=l+ARRXQvHKMU5YamYFAJfDEOefTeHsJ8tfZW4B8X6TK3v3Jwaakjx+U1pHfMAHcwx
	 Q86v8GbmEPKJyzUSVNi+UkaEQyUxMUvkdoaDIuP1jfrXrK1eY0cgaIwS0u7B6YGtqg
	 K0XRLxp3QYaRDEZdWflE+QKMdDSBF6qUaQEgbGqs=
Date: Thu, 9 May 2019 15:54:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Cc: <mhocko@suse.com>, <mike.kravetz@oracle.com>, <shenkai8@huawei.com>,
 <linfeilong@huawei.com>, <linux-mm@kvack.org>,
 <linux-kernel@vger.kernel.org>, <wangwang2@huawei.com>, "Zhoukang (A)"
 <zhoukang7@huawei.com>, Mingfangsen <mingfangsen@huawei.com>,
 <agl@us.ibm.com>, <nacc@us.ibm.com>
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-Id: <20190509155449.ee141be7998256015ea0eb73@linux-foundation.org>
In-Reply-To: <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
	<b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 May 2019 22:06:38 +0800 Zhiqiang Liu <liuzhiqiang26@huawei.com> wrote:

> From: Kai Shen <shenkai8@huawei.com>
> 
> spinlock recursion happened when do LTP test:
> #!/bin/bash
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> 
> The dtor returned by get_compound_page_dtor in __put_compound_page
> may be the function of free_huge_page which will lock the hugetlb_lock,
> so don't put_page in lock of hugetlb_lock.
> 
>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>  Call trace:
>   dump_backtrace+0x0/0x198
>   show_stack+0x24/0x30
>   dump_stack+0xa4/0xcc
>   spin_dump+0x84/0xa8
>   do_raw_spin_lock+0xd0/0x108
>   _raw_spin_lock+0x20/0x30
>   free_huge_page+0x9c/0x260
>   __put_compound_page+0x44/0x50
>   __put_page+0x2c/0x60
>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>   hugetlb_acct_memory+0x104/0x378
>   hugetlb_reserve_pages+0xe0/0x250
>   hugetlbfs_file_mmap+0xc0/0x140
>   mmap_region+0x3e8/0x5b0
>   do_mmap+0x280/0x460
>   vm_mmap_pgoff+0xf4/0x128
>   ksys_mmap_pgoff+0xb4/0x258
>   __arm64_sys_mmap+0x34/0x48
>   el0_svc_common+0x78/0x130
>   el0_svc_handler+0x38/0x78
>   el0_svc+0x8/0xc
> 
> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
> Signed-off-by: Kai Shen <shenkai8@huawei.com>
> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
> Reported-by: Wang Wang <wangwang2@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

THanks.  I added cc:stable@vger.kernel.org to this.

