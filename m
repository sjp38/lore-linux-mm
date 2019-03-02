Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61A4C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 17:10:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83AB820836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 17:10:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VrhHT/SF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83AB820836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140988E0003; Sat,  2 Mar 2019 12:10:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EF7F8E0001; Sat,  2 Mar 2019 12:10:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004258E0003; Sat,  2 Mar 2019 12:10:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B54AD8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 12:10:48 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x17so804123pfn.16
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 09:10:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iUJpS9A7ZzMrJTMfM9wjaUGS6YRW/mugbkMQHwyjU3c=;
        b=djSfv6O5/gtnrZP0gbFNpwgcT+vy2QPpFTBNhQvS9LX5ZhyBk6nfislezrzSgj8hHo
         tU1El1xFthlfgCvRcm7d2g04pMMRWRMD1Kw7KPJcXMw1b9c9eGgdGnlSl/jNAwFESf28
         NFD8njHRi2sp5JdZKIlncLY/8yQLnhOetD4om/N4nEi2bPVPCcz9mORQFOC8G28OtaG4
         AryYCZT0rzIJI59pNDLKwxkwgBoBDtRAF19YmqWzKyxVYt05NeF4+KpEAstyYxYWwumN
         X82nIe2iN57/W6bUaBFyi96Ha7BkKelLEjOQbzHm99Y6BodEdP1mrhLD9BJccz1pVggd
         LrUw==
X-Gm-Message-State: AHQUAuas4GMCIxx5Tr307wIlYyPSGWXGGI00kMEUD97zrxLM+OihEUkV
	C7z6xnvO4ef3veSZA+V/tdf4ZmQp6fjXIi8eFCXS0PG6iNhaetCR3nyA8nJd8mDstoKt1ksgF4E
	B3TEqQaJ8VkXwFMPi+nXwiFIIBfJv4whTt5eLrYzYDELmLBmdxMarLpBth6qFdqSUXA==
X-Received: by 2002:aa7:8c4d:: with SMTP id e13mr11683698pfd.53.1551546648353;
        Sat, 02 Mar 2019 09:10:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUoo74M2z9c6YAM6rM+ie4+RweaMITbMGMfvZm28L/IUpjQa1OWWh9jwPiOzrVZYN+BVHt
X-Received: by 2002:aa7:8c4d:: with SMTP id e13mr11683616pfd.53.1551546647423;
        Sat, 02 Mar 2019 09:10:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551546647; cv=none;
        d=google.com; s=arc-20160816;
        b=YoX3ZKgsdLpjfo+Un4+7/ZYY25rdzEdlV+Ez0qOXYVBhy9A04ziZeDLfcvjrJSq+20
         0nd/EAebG4Wn0j/g6KMiHOFDYQMT8apjOSSqmQd4beCRQXIBicQDyNAnAQEh8sDltqd6
         MlDdC01x8navY8XNAEbTxFej+MhHbU5TLX9LYfoWYCmRYNgHipDeRvD2QFycCojwveZq
         uGFbya+VHejwrGnzz20nrsLWqDp+t8/q4CO9A6LBY1Ibx00tcTbG79h3TMMeOcE1PR6G
         OqLm7AAki4nqt9aotjBDVc/li+BtIMZKSyAXd5xIkKc4CZnR4ltz1Ro+Cq/4fVAS8Ig6
         lLIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iUJpS9A7ZzMrJTMfM9wjaUGS6YRW/mugbkMQHwyjU3c=;
        b=H/ulGZHcQNDBPBS5GsYXo8bA2eqdk858BYM0ErHAiL/jH1rLHAErh08+NavAMl82Wn
         KrujtujS2deBvKKXwgFjeve/z4FqnZdhtwvV7RqW2pSlagKRd4vIm4RlPOicvxZIxKAV
         zN+klCM/uPCKfugt2Aqo6MyyvfTODJr3GQw3YEAVuFdTtWissBZNvjKu+7PSgucMorU6
         NhUvg4D59P9415jTErXmsCJEd8SUgE158M9gmFEAdpHvDpbNdhebYHN8PtwR1Lw+eavH
         7GjmAO+hZU1qCRIldxLKHe9my2dkyKKjLIKQRWP3c2zsoRVBi8Q+Rla6+wbL0bk4oXMS
         S3Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VrhHT/SF";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y1si1040013pll.214.2019.03.02.09.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 02 Mar 2019 09:10:47 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="VrhHT/SF";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=iUJpS9A7ZzMrJTMfM9wjaUGS6YRW/mugbkMQHwyjU3c=; b=VrhHT/SFMXPETVeAq1YSXTeBW
	65MvdxYfKvg0Y4DbNi4H0kG/heLRzKRpmnbi8IR8LqS5MNzDKZZGdl+Kdd5ufh7E2wR9NQccirf46
	qVPY9bV6vplt2g6YulCga7ehLvhr6X7hAlAWqW+Zh7IDSDJfsUzHwPOL6nrVl9Uv7kg3BftdxH4he
	NEZ3JMoYIZJ+zGgm7eX4/MeCFGAOSbMZPHM6DJ6SfKAx77EBQjkq8Ahruzcx841wPGlOmDQ+tWi67
	Tg4ZkQt7CnpLXpKsg71Iu2ZYyyZfq4DTKB3m+27+rLLtc5xZ6sbZDUZveXfq7GyFNSMII82NV2Y7i
	OPEggghng==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h089s-0004Ts-1J; Sat, 02 Mar 2019 17:10:44 +0000
Date: Sat, 2 Mar 2019 09:10:43 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org,
	riel@surriel.com, mhocko@suse.com, ying.huang@intel.com,
	jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190302171043.GP11592@bombadil.infradead.org>
References: <0b7a4604529e16ace8d65a42dac7c78582e7fb28.1551538524.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b7a4604529e16ace8d65a42dac7c78582e7fb28.1551538524.git.jstancek@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 04:11:26PM +0100, Jan Stancek wrote:
> Problem is that "vmf->vma" used in do_fault() can become stale.
> Because mmap_sem may be released, other threads can come in,
> call munmap() and cause "vma" be returned to kmem cache, and
> get zeroed/re-initialized and re-used:

> This patch pins mm_struct and stores its value, to avoid using
> potentially stale "vma" when calling pte_free().

OK, we need to cache the mm_struct, but why do we need the extra atomic op?
There's surely no way the mm can be freed while the thread is in the middle
of handling a fault.

ie I would drop these lines:

> +	mmgrab(vm_mm);
> +
...
> +
> +	mmdrop(vm_mm);
> +

