Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57F66C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F532087E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="ZgvZaUOm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F532087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A46B8E0003; Fri,  1 Mar 2019 04:37:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82ACF8E0001; Fri,  1 Mar 2019 04:37:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4A78E0003; Fri,  1 Mar 2019 04:37:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23A278E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 04:37:36 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 36so16258360plc.22
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 01:37:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=E6lL5RDtVl+IJ5vYKIvzIWgcL2Re6vneCTK9vQH5tIg=;
        b=PNIFMXqdn30P4/P4guuo1swI+DvrNr8nn+xjkpbO/BN4YFJgSSOrdD3I2LVIshqAK9
         +IuDsaV75yBqkh8AzlTKZM8l8MDCnS1Eh6aordkDT8JQAEtjXeafKy8DLC/wTZU9HJ9H
         SqK0sH6iTnIKv03NvDJ+uXkWnIY9ZZnAshOdilg7lJOLzWTk/YlEtKrgUusmps6iP2xr
         1zCPjruBkU91CFhTpMan4SNeemx92ezkBS0CRYAtpCIu/A6ycUklir5KRv/hWHC57G/V
         AAzI1MnpGr9wv+wC5RQVsvoUxC1CIViGqDEAPxqHFfd5hn7EA2mbvEH8pKNS+Mw4w38v
         v6pA==
X-Gm-Message-State: APjAAAUsdMDt7eAP9fmHDdTqdP67GuG5e7iwra5YOjpj7s+0Da3MGWN0
	BNGPTs90/ZJJGc/74+qrzGqZPZXTllqJfr6vjjsOXmISFAcMPt6yop/7n29lnHaCGhsXJK7dfCj
	tPo4j2BMjj9A3//AKXo0DXEenN8mYiKWqLLVngcZcizHb2XFxnsBZy6sP3LEWQsxQFDxWaqhsjG
	MygBqvQ1NysQUTBN5TxSL08dG5VrVVhnqUg0Cx1KVUCe6g4fbEEFstxUzgFqri1cQSKHnZHAZ++
	70p91ihrSMHTub7vGkrMyeYyA5GUlxI6oZEDDBp4kecHrVUxeism54oG8a5FLucLUiCUw4PnEHu
	n66a0nGjMSMT9fTgdqPTGorMpcVHHJAm3lRqcLHjhlRGCe+3B91CuU/LjeBBKjb4D5UJNuUrZWE
	L
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr4545880plp.8.1551433055656;
        Fri, 01 Mar 2019 01:37:35 -0800 (PST)
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr4545821plp.8.1551433054733;
        Fri, 01 Mar 2019 01:37:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551433054; cv=none;
        d=google.com; s=arc-20160816;
        b=NPyg1X0udm/kC/N52Y21FFTiAjyA+FwlNmOajwUEVcij/i2owoLXy9SqNPvApOAZ+b
         u9BUSFf08l1/p0ZNNjAFfey9sok78QinVGBEf/ZpVqPnwANS/KYR0E+IUFmJlBH3Afku
         Zse7Y5gTCrHlKsOfLzvn1cLPtvotlxTXmWY31VAR42ZF064CmsmWb8/ucSu3ivGuXLLT
         j7DIuUd1qkiIn0G2jia8K005qU8E5hSc7aRmcFTEtehQV2O0tNxH6808lmZdQcGHJZem
         59LY6rYBo+szyaAMLCBF9Rr+zbJ7XR1BTYunMtRGxlHYdhC/rAJoCEBvtE9pAg/vvNFE
         5pVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=E6lL5RDtVl+IJ5vYKIvzIWgcL2Re6vneCTK9vQH5tIg=;
        b=Fmr+sUqrfjHkp1kkiNa7fbXxlEJ5tQF8alX/ZKJL9Ci0rCFAQtdxXgbTj/Si9yN1h5
         iXCu93c4syfoyEInCyb6LU9UZn0Tv+hfKnojmbFxCMYacvNEPZ+9ttUVwhsK74oRqkla
         W1Dp9mw7jTZfyvqHG4iOnR3wHuAnJ1LHPZ/TLYZp0WzlSD0XBQq/dV2TGbrsp3UgCZhb
         ewz8BUFcE3r5/aHj69Jpqu0vR2zB4tZ7+6ujnTawBPufxaTkckMx16PlzZk0uCmcVEzn
         ab92IrincqsQ8xw7hJvLHQPvhCcSfEyJCaPA0ljYE1MZXM4sF4IECEHvXjw0Y04dEd+7
         LpIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZgvZaUOm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12sor5649401pgj.56.2019.03.01.01.37.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 01:37:34 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZgvZaUOm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=E6lL5RDtVl+IJ5vYKIvzIWgcL2Re6vneCTK9vQH5tIg=;
        b=ZgvZaUOmREEjHE22N8/bNctdvY/8T0+glmHJNIYKTeS4lFAgDdjBCW67IyjE5KgHUZ
         cfi1J3jjITZaIx5PRVdT6uevuaz78LKxXvXTGDDdvTmYqgc86ay+8kf47uriUSoDMxGk
         Vx7niRgGk8I9TGkDb1OOf458zL66fYkVMS4pD/wM7dHoj59BXsUt3/NlxuczaVTTaPB/
         3KZ7DEj7eVSYNBl1O4RQjBH2lObR+7zeuJqHFeZGH2pgA3EAFDNLY/T5Pf/20EgIuEG5
         cRenX/Ot+SRda6qrH6quublFKukaCoCn3iuTa/sioy/1kHeus8Gy3JQMuN1i+EmvJdRz
         X6jQ==
X-Google-Smtp-Source: APXvYqymNSRFAIbBaB39Miu0X7SXQ60wBoi+4KTrMRI+cQULdSYg/9G48qk4IQSEqZjlUbuWwRGTEw==
X-Received: by 2002:a65:6091:: with SMTP id t17mr4014014pgu.416.1551433054081;
        Fri, 01 Mar 2019 01:37:34 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id s80sm17771798pgs.4.2019.03.01.01.37.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 01:37:33 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id CA21A30BC0D; Fri,  1 Mar 2019 12:37:29 +0300 (+03)
Date: Fri, 1 Mar 2019 12:37:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Message-ID: <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
References: <20190301035550.1124-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301035550.1124-1-aarcange@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
> Hello,
> 
> This was a well known issue for more than a decade, but until a few
> months ago we relied on the compiler to stick to atomic accesses and
> updates while walking and updating pagetables.
> 
> However now the 64bit native_set_pte finally uses WRITE_ONCE and
> gup_pmd_range uses READ_ONCE as well.
> 
> This convert more racy VM places to avoid depending on the expected
> compiler behavior to achieve kernel runtime correctness.
> 
> It mostly guarantees gcc to do atomic updates at 64bit granularity
> (practically not needed) and it also prevents gcc to emit code that
> risks getting confused if the memory unexpectedly changes under it
> (unlikely to ever be needed).
> 
> The list of vm_start/end/pgoff to update isn't complete, I covered the
> most obvious places, but before wasting too much time at doing a full
> audit I thought it was safer to post it and get some comment. More
> updates can be posted incrementally anyway.

The intention is described well to my eyes.

Do I understand correctly, that it's attempt to get away with modifying
vma's fields under down_read(mmap_sem)?

I'm not fan of this.

It can help with producing stable value for the one field, but it doesn't
help if more than one thing changed under you. Like if both vm_start and
vm_end modifed under you, it can lead to inconsistency. Like vm_end <
vm_start.

-- 
 Kirill A. Shutemov

