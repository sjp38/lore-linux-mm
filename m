Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E178EC16A69
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 23:18:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A334421841
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 23:18:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yTbP1ahd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A334421841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33B6D6B0003; Tue, 21 May 2019 19:18:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EC596B0006; Tue, 21 May 2019 19:18:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DAA56B0007; Tue, 21 May 2019 19:18:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC9B46B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 19:18:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r4so373124pfh.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 16:18:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XwYvZgM+Rbhl8BfTHBR+tm9QCLA8pFaBV1ysaOnT+Ok=;
        b=qllk90p5SxlR+a5saixXT7Q0ghQocAAbCuDQ5neI+4H2oN9zsbbhsXfWExLxPMxgxj
         FsjoFSVUcSe4ZlpZXa6/F8GKYJZLY3Sy0mkVB6wmHHjEZyVvNOByZxe6CLECoZ+KNzgk
         Il6VLA5V98nlKRmtdiLmJqpDtaC0hVWdycCOZVX4BZ2fsD8aBHuQsn+GKsld8yJsXlZJ
         K8BuJ9gMPlMJ8Wk3IxzZbtO9DQZRG8QZbnaThCMO1Sq1elHfOwerXco7XyoUeJXIh7CQ
         sGHUXt2RKlPXjR4gKS+4hCzxnYoTouh/dyaVqtqmdKNY8RlYAEflESoIamNYcJCkkgKr
         LrFg==
X-Gm-Message-State: APjAAAUq/7B8CKyRJD2C9p7vxEJovvA3TVe2+gbl4uCqXe/jW+rTx0JO
	IGFbT3T/OhT8s8p3Hsp9RuGbJFdx4jDYw4znDHMJlrwoNvXYYs0phwl5YeW2cJqKa+/Rtq867eU
	lFuIIU3PMlOrGrGdjUXi+dMfCLXVU3Kz3mOcK3+CZQlxN7yLmNTLIpP6VlKFUXhPHpw==
X-Received: by 2002:a63:e645:: with SMTP id p5mr85592960pgj.4.1558480708403;
        Tue, 21 May 2019 16:18:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+CcAVeF0HOcQ2pGOZfr7dc3AnFkrbYyJ+8HjwOyqRMsqfF56IDE92PDLKo3nD/7LyqDuB
X-Received: by 2002:a63:e645:: with SMTP id p5mr85592889pgj.4.1558480707487;
        Tue, 21 May 2019 16:18:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558480707; cv=none;
        d=google.com; s=arc-20160816;
        b=Q76mG+aR+agUL0/j0QDoz0nX9bbJKFNuzQMty7xmbbrOIdk61ypsiiUrZPL01r5s0x
         P1KcmGAdpkA0/Kv50JC+brTZflYHUd2mACdZrm9IZZMoz4uCxdfLj7hMYnI7JOCVjgTP
         WN+sjzYZsV7HRWYcfTsfmty270czZx1NaNt+BEjuq7T7mirtiV6Eo6MQnUFhbx6rOorv
         OlWeaHoRTY5Wxeq3zi4pBQcnuvAcVhzljmYX8gnow5Ytc6iJzmcWUZjR0rboX5Ii+xDS
         MEcBBfRadtDLMJln7r5KPh0D1n9CWZTnA7SR22osEh8Oejeud/rmX/ViLbAufmE0g65r
         C5xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XwYvZgM+Rbhl8BfTHBR+tm9QCLA8pFaBV1ysaOnT+Ok=;
        b=IhhCDOQH4Y0x5Vtwuo/BhHR9mk8hbVptG36eLmsFtXneWNHL2P4iSiPmq2gaV8d2ne
         pq7BGufGVbBsJdPTKJ1edAciENrf84PyGzos0Ond4TDfJhW53HfEFdk4XAURbMWii0Fp
         02KmVmOuIhzry5jeE7J43pA3XdYcI9Gf5aUHs0YfTwzIW8jFPp+/tYyeFsAEw9du4i92
         dku8j73du9Edo3/csBNDs816KWl8MQI2GmsCTyS3bVOrKKoKpDwyxmHFuBOmX0GkOuwZ
         ysyokZnqkn5Qz6ydVDgNa+rbPjYRuv3lcNk1XXvTmcwZ/Vlbg2e3lvXiljgFTiYqttTs
         DA9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yTbP1ahd;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w4si22088127plz.27.2019.05.21.16.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 16:18:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yTbP1ahd;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A07CF217D9;
	Tue, 21 May 2019 23:18:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558480707;
	bh=OqZTLBGMOxuOEC5Xxc6vRFdatZp8Y6uYyV+vbDmpUTw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=yTbP1ahdfFWzH7+xIWDO3zK+bnX+jdec5gDJ+S/QtXR2kr6MEbshxQ6mcMgnmMNGy
	 gn2nS3dR3xPTuzc8voQ3m6rV/qgZf9Cl8sN876UHucJAhZtf+5WgXTAQKk4R571MbI
	 7ZTGPXgAWWaaaW5Wme4VZ07yTB531bWnJZwnlzWI=
Date: Tue, 21 May 2019 16:18:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: jstancek@redhat.com, peterz@infradead.org, will.deacon@arm.com,
 npiggin@gmail.com, aneesh.kumar@linux.ibm.com, namit@vmware.com,
 minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-Id: <20190521161826.029782de0750c8f5cd2e5dd6@linux-foundation.org>
In-Reply-To: <1558322252-113575-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1558322252-113575-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 May 2019 11:17:32 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> A few new fields were added to mmu_gather to make TLB flush smarter for
> huge page by telling what level of page table is changed.
> 
> __tlb_reset_range() is used to reset all these page table state to
> unchanged, which is called by TLB flush for parallel mapping changes for
> the same range under non-exclusive lock (i.e. read mmap_sem).  Before
> commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
> munmap"), the syscalls (e.g. MADV_DONTNEED, MADV_FREE) which may update
> PTEs in parallel don't remove page tables.  But, the forementioned
> commit may do munmap() under read mmap_sem and free page tables.  This
> may result in program hang on aarch64 reported by Jan Stancek.  The
> problem could be reproduced by his test program with slightly modified
> below.
> 
> ...
> 
> Use fullmm flush since it yields much better performance on aarch64 and
> non-fullmm doesn't yields significant difference on x86.
> 
> The original proposed fix came from Jan Stancek who mainly debugged this
> issue, I just wrapped up everything together.

Thanks.  I'll add

Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

to this.

