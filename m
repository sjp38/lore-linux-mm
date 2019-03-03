Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E41E6C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 10:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9167920830
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 10:36:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ItMXoLP3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9167920830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 252F78E0003; Sun,  3 Mar 2019 05:36:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 200718E0001; Sun,  3 Mar 2019 05:36:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1178F8E0003; Sun,  3 Mar 2019 05:36:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C78E48E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 05:36:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id j10so1987426pfn.13
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 02:36:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7IjQzc5Ln//S4zZ0N/Bu05+ec8v0TqIieGmd+VE3W7Q=;
        b=acNx1Trv/z7MN0t1BQ7u+G2AZv5OXtgEOlMsBf9cO5yLmAtcPtIYf/7Wd/0tB7oTqo
         RgcJDroYECcRQHJ2L4pPYBbzAyQQGaR+pmPDlhoc7hTK36M/qPrYtWL5pVU8O6TMtFe7
         w94JrxXjbb9j9vB6tKaFn33U6GSTTLXbbTCnZ3KNTe5URh2p2EfWV1myK1PvvAr+A6sy
         PT7RNC2gMfAsrdHq8puecwgwDnPBhv9DpU/oaEKAVKBpq4ZSbFkuPeCuJhdjaMIbX69l
         K3xQjsZRU0sFM6jeBhBWIcryAVqKK1i9onkxbc4naJ281OwDiu1kzYKUatu11FFb5MjG
         GIYg==
X-Gm-Message-State: AHQUAuaXJHyWUP34BRKgnKswgEt6afkIiqwuebscZmN2Y5zizhuVATrE
	Dr8FC2rL68PRFp30tQlemSnmZTzqj9H7EDGwHenHEq2ttNlh2tJYiaFrhlqtxjfboZQ5AX36rvV
	WfiRuu9ueaVuTxR65zrdTZwMZgT/15SYATal2RefH4xuNwdJ7ns8QT5Kuo5MFFhQ/Ag==
X-Received: by 2002:aa7:9289:: with SMTP id j9mr14769649pfa.130.1551609386382;
        Sun, 03 Mar 2019 02:36:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVuGEQWutuV71lOuWl3smKFc4aCbJ5rdY1bufyrmx3mP4nNtJ/qKp2Q178f1aAoEnXIlBT
X-Received: by 2002:aa7:9289:: with SMTP id j9mr14769600pfa.130.1551609385376;
        Sun, 03 Mar 2019 02:36:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551609385; cv=none;
        d=google.com; s=arc-20160816;
        b=G7Ckqwxpcdtnsm7QwX2IqaKw9S8NBqDJzJ3Pi9ewO+2Cg7E5pe5m000gpjadChYfwA
         AzCr/2DWmVOjCdCv7onc2xSK88gL6K6VyDehP/15Nnb1X+A0PFYZbUOE4lhlaWCr0G4I
         QqUFr4sneweiuEaDy3uVkIcmt/GZvte5qntDSfTs6e0onf/g0v/Ts7IOxpTOMmU1sM0J
         VbWFnNLlN99Qd6vxS3B9HaNNXPPFn8oPmBT5DeWJ1kdv/1tzwEmrGz98Ry+EcAuF39jq
         M/L0DwcHc3isjnQg00eE/yot8Mdj85+2RESFU/1XWCjHHm1iKu9+3XUMBImMis7ptMdh
         DVyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7IjQzc5Ln//S4zZ0N/Bu05+ec8v0TqIieGmd+VE3W7Q=;
        b=O3wIoZQVOQHbiL2ik4tp5GIGfkCB/UJuTit160ATPrLtcI7K8HGtrfWR/ELzwNA8uD
         LCILzMz1vNDhkCfYJRkFugur0H54UsTNr1VXAe0llDkNjhIQIUcZwzGz1flNt83u5c0i
         IUJUZH95bzrW0U3MP51DatJzfS8ksbuAM90yME25uemrHtpuwStNimolJZhjlqvMG0Bs
         dK3l2UmqNc3lP/4DpP1h0l/N3wBCom6Y5GIK4wcU63qZs1FvXE2tRNY3lpDce179VxS9
         ncGFFQvKkj9AwTAjf5XwFsuzBPTY6aehYitjnw+Gl9E4byL0rnDD/PDGuHMbPuVhvZcs
         MEbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ItMXoLP3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i6si2536224pgq.423.2019.03.03.02.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Mar 2019 02:36:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ItMXoLP3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7IjQzc5Ln//S4zZ0N/Bu05+ec8v0TqIieGmd+VE3W7Q=; b=ItMXoLP3yks8/7WyF9vb0YQaH
	MlFHx37O+YpCoKsjv/SMuXP7P2rtGXJwojaGMfnaK4VExz5UO9zuXk0LPf/wfWxPLcg8dp0YwOpH2
	DAGYq7D4EmXaIFsfwwbUc2kUOhNfPhkyxRA6NGNOYfbGGfX8iFF6M7do24b1WD8C+uEYeGhyZvhJ3
	N3XTiKCzfJlgT7RSbu4GE1/BFTzFgvcbTv/7SXtSyzGo8yGr7YasEL8N/V9a4+0z3Cx+4JMMs8l9d
	Ys+hjkCaMlv/snb94QYorxk0u+oPqoETL33hyxsPSBZPB5aV8FmzlDC37tJBg2YSNMAJXSvSKLyzV
	8FBH+16OA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h0OTj-0002AB-9S; Sun, 03 Mar 2019 10:36:19 +0000
Date: Sun, 3 Mar 2019 02:36:19 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org,
	riel@surriel.com, mhocko@suse.com, ying.huang@intel.com,
	jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190303103619.GQ11592@bombadil.infradead.org>
References: <20190302185144.GD31083@redhat.com>
 <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 08:28:04AM +0100, Jan Stancek wrote:
> Cache mm_struct to avoid using potentially stale "vma".
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

