Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03602C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:52:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF8DF217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:52:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="j7BI8t9w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF8DF217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3293D8E0003; Tue, 26 Feb 2019 08:52:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B1308E0001; Tue, 26 Feb 2019 08:52:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 152888E0003; Tue, 26 Feb 2019 08:52:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2C8B8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:52:02 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 71so9819794plf.19
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:52:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lLK3BfRxB+qG/aPDalW8MkM3Flr+0berjH+y6Qs1Co4=;
        b=dZpnWDByMgxFpeoo04nOJikDVv28pJjzT0HsD3Pns8UTfBIoKYziVdjP1LBZp2iqJh
         /A/LE6plpI60U4bq0EB2PYCcYslcooIH63js882ILegiQjLHklLht4ARCf7u4+0naX5u
         VCJcRvGcX77g1NB5p8BoMblRX/gFhkh0IHVocWlTKpV5tHAGXc9LwvF8alDSx+uXiIFf
         H5IwQGehT9Fdk/502hsuuhKcqLFPi0x206Xtm8YQjdymKy7crWyNvZP8dtYSKGH2Tstd
         mcGtsClbcCNt0A/CVIC9qxijBmXn89CYWGdaSM7yCYwmCUfZQcz8lBPkQ6uXHb4xYRia
         YRXQ==
X-Gm-Message-State: AHQUAubAxSwX4/AtW1Cmt2vXkF/QzkfMeM9v4izawqqWCofh5/5r3zhj
	LCp1HcRENt9hshX7ztPvAnwv+aoANZhuBb/bKPD8bCzY1E9wNSrUEkC/iDK0IaKLWOhrA0ECNC3
	/aPsZdzOMomsXX1DYGvLUhZ7UTpkTc8dOobLE9uFd7TedE+dy5a9g47ued3wBACp31jERWWgl3u
	RjmPZesMoeRM1tCDWN2l5RrmADzynZLdPdekt2WLSXMzlIX/FAlkpqAExftA4TyQsxVnrTTEY0P
	MXyjTixzp+LIQeqnGAlZhtw11gmNO2xi1abRHRuTgxPSAXoks579EhZbOAqg9rEjooJMuamTt+k
	N59xqE80GwjJq0IGAeb+WWEMBygFqSmzliFIsG+xovmBO5kbkiE5cJYaiRI65BkXGf3cJ4nO5vq
	Z
X-Received: by 2002:a62:458a:: with SMTP id n10mr26827484pfi.136.1551189122416;
        Tue, 26 Feb 2019 05:52:02 -0800 (PST)
X-Received: by 2002:a62:458a:: with SMTP id n10mr26827413pfi.136.1551189121347;
        Tue, 26 Feb 2019 05:52:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551189121; cv=none;
        d=google.com; s=arc-20160816;
        b=afqgqmHsevKTpxmlSgRHnkQYS2F+Dju57XHuEe1mkpyYovhgjqWSB4MvbPwoEO2XQD
         SnurNQTzMMzoizUeeakzsSOn9QsqybBd9VNmK3gRo9mM5/abYHtcSnO6Qunesq+jV3Kr
         fuU26+QmH2B0ZC4lNuHuieCDINn9FUUzTzEbIctxFw8GKxb+Hl6bmwonciqv+XzuhhbY
         pvOqs/6zUuPDcDMmDxbG9kyxzwjrvK1ZGcR+RoAucglGIMnhH4LnU6pD532beD+e8Fhy
         mQUBLaJhoHIuMbzmoaSm2hLlkj1Y5c/QF4j9iB7QCrsrhPgyKWTJ2IT2NyC2xukuEZBQ
         mMcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lLK3BfRxB+qG/aPDalW8MkM3Flr+0berjH+y6Qs1Co4=;
        b=oRJLZM7hGcus5ZssEqzKheMaCasCc+60vSANmi7jm9XkqnQxBW2bkiJ2F5Qqs/AQ3s
         rN2wkhG0e4AuKB9cF4Gc29w44f7Ezd68mfHqKuawJBMfObNlV/sV4SeAkuLa+cHzFocm
         Wi71ozU7Ep5dUaMCiJylUiRdROtememlIYN546zTNm2ugko6xuua2/fFwwljBdO0ksbJ
         2TS/oyNIW+XjrJm5QX1mGcnNxhxBhReCmDdvhR+J/pTjcQL6TIDEqZF707eQcPI/OhvI
         849mpLIffRWYdx3RmFjbwp5TJHhTuoKBXkf3Dus04V1flr91Hk4fQ6cg3L6s2W1dlo9U
         VS6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=j7BI8t9w;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y191sor19138683pgd.38.2019.02.26.05.52.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 05:52:01 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=j7BI8t9w;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lLK3BfRxB+qG/aPDalW8MkM3Flr+0berjH+y6Qs1Co4=;
        b=j7BI8t9wmBNjRxMmV65x2O7XXA+jv1wklMcOpP7+aNgJlnbw1zPeSxFQgpNtoX+ZQI
         eFiIM9jI3sNGzA5n+wH4wuWRC/q/55iO+ZiS1yyE9iPZHjuvooh5aY65vllpzR2Lhd1w
         1o+hEWiT6fXCAXIEA2kZtlt7BqYXmoB0rghGS6otU5i5zZWL0nqH+6lJkvGSlNnlM2j6
         32Lddsc15Z787TELQglsClmm9TuUA1tSuHxRQPvHqbg8eZOhkBeJJUc0Rex09C6qMTk7
         Nd+Sq9tSgm9rKrF8IXOhPCyuQbaLbyewkMjixgzPKefrg0wP0+hjAGxwzymwqHK2/Z3T
         NKvQ==
X-Google-Smtp-Source: AHgI3IZd3zVBbQWjyMgY+Z7Oz13Tb3/AGplZ85+WwAk1xAZ1FVZY2VVm5+hCThgyvG4lEVLuRwnWFQ==
X-Received: by 2002:a63:4b0a:: with SMTP id y10mr24504308pga.66.1551189120787;
        Tue, 26 Feb 2019 05:52:00 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.41])
        by smtp.gmail.com with ESMTPSA id c18sm3626873pfo.44.2019.02.26.05.51.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 05:52:00 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id B569930064D; Tue, 26 Feb 2019 16:51:56 +0300 (+03)
Date: Tue, 26 Feb 2019 16:51:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: zhong jiang <zhongjiang@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
	hughd@google.com, mhocko@kernel.org
Subject: Re: [PATCH] mm: hwpoison: fix thp split handing in
 soft_offline_in_use_page()
Message-ID: <20190226135156.mifspmbdyr6m3hff@kshutemo-mobl1>
References: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 07:18:00PM +0800, zhong jiang wrote:
> From: zhongjiang <zhongjiang@huawei.com>
> 
> When soft_offline_in_use_page() runs on a thp tail page after pmd is plit,

s/plit/split/

> we trigger the following VM_BUG_ON_PAGE():
> 
> Memory failure: 0x3755ff: non anonymous thp
> __get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
> Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
> page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
> flags: 0x2fffff80000000()
> raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
> raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
> page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> ------------[ cut here ]------------
> kernel BUG at ./include/linux/mm.h:519!
> 
> soft_offline_in_use_page() passed refcount and page lock from tail page to
> head page, which is not needed because we can pass any subpage to
> split_huge_page().

I don't see a description of what is going wrong and why change will fixed
it. From the description, it appears as it's cosmetic-only change.

Please elaborate.

-- 
 Kirill A. Shutemov

