Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6360DC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:08:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E13B21B1C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="LK3eHapj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E13B21B1C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1FAC8E0003; Thu, 14 Feb 2019 17:08:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACEDE8E0001; Thu, 14 Feb 2019 17:08:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E5618E0003; Thu, 14 Feb 2019 17:08:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2448E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:08:15 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id i11so5308296pgb.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:08:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mFDawymT8Zh+E+HOem14TYUCVAe8NsegNwIXcLtnH/8=;
        b=a9EScgVIt4TiudANgHtfBp4jTkVDqHnqtuXgH4jlSwZgHlXbSpw3oXeB+fGxySsnlr
         /0oLYtcHUN4mW2TKYmBfkces4Wm73R0shO6LvKYkSxCu2CvDadc3ZcftyFoRksC2dvuC
         ratkRGyXqwX5J6EtlqldojWlih3I3fE65rOkJa5cTV+dGoSEo8RmUV9WefEXzQYi6Koz
         uy2vkn8g8QE8cT4pOMgZLLySH0O5w/KrBnrwOgI1opLPtHm4WaBOgcdsltGB63/VyJ/n
         uJ2TWU2cWUqhmSoxUEoRfTudOTtAWgfB/8cqpadO3RilEwG5M/qtiOAWzxb2z3tACp3c
         s9TQ==
X-Gm-Message-State: AHQUAuZOp/wOny+C5Lk4jnPy50n4d4MeBDkVAZ7cw0rV1glTDDP6TG6Z
	cL0/KXjFnbjxFZAUiwK8QiQSKXYZAoO/+pMutAXkME5o6+jZa/lLI82flv+SSyktXPNeHbkevSY
	Lkal7WxE1qPNVhRA1FRXc7ibk5QujiCODwVTreCc06jfg6Z0YyOQBE8TLoEew40TwnaZIwoGBiJ
	mCffZM7LYZqvWUFtJK9e02SLAR2HsiMI11LNUYSMDrGN+t25ci27zfPoHy1w3GgIgOUPn0oj7ea
	UwmZS5gTMj8olWnjpwgUaJkyYHtkGMqIe8bQQpC21QrLVG9hwuACuZ1ql4wYeG6p6JPNwG8Z8se
	19/YP+HAVe5vTYWDOHgyXiH585IrZKF1f+ezm326PqvmhnSYmgK+Zl7W56aV71fVvU02WM2ncF3
	Y
X-Received: by 2002:a63:9dc3:: with SMTP id i186mr5935759pgd.305.1550182095041;
        Thu, 14 Feb 2019 14:08:15 -0800 (PST)
X-Received: by 2002:a63:9dc3:: with SMTP id i186mr5935703pgd.305.1550182094416;
        Thu, 14 Feb 2019 14:08:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550182094; cv=none;
        d=google.com; s=arc-20160816;
        b=B2f1eD97umedDJyEb9GcVND4bvIEewh2wpR9D6Uh7uml2HWK6SVJwRoWm+jtHP3Z5b
         nKUoCePhCoX956exQaOP51nNHq03erFwxi6HeJ1Y3PKrtpwUSd3Fqlbh9XN//hHucsuF
         spalXd1DkgXOiJHc1CeuRVrWu7vJwbEy7OQChfb+QDSxOLm1901h7LFZGWcCKwRzDZw7
         K/OJ1lCzqEGvd1aAVqaxzAsKXCgcf6M8/ti5ydjoFbz+mbuDvkbUJ/9KyORwaa3hL9yQ
         emlQBpgOK5enxIFpLGsVZRpk1w0mPbvVDe8B/Pv09Ci8o8XAw86wIoedFvxj49TQkCEw
         e2tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mFDawymT8Zh+E+HOem14TYUCVAe8NsegNwIXcLtnH/8=;
        b=ay706XBl49sldMcKugy/ilWPIQERm8cBsuKXQgsumcfc3UVnEfToAU8cE4HQt4HGFx
         8aLdcpm2WLW952zKRkbg7Kbwk8niYrny5sl0IKf/YWrSSm6HLoTRq7x0KdWP11FWwdPc
         ypvLEcB5qfwpkAFNVr1bJKfVlCMxCJFhqHpim+bh9eOp/0G5qSo3egMRwGZovHpYgwI2
         V9m8TnK22FHqEc32hm3O/obP7zjd+Fx9l0lkqmQZ/aPHAnrklqZjnWgcIU5Yghffp/Fk
         mpdMr62zHsnTtyy7y2VZgre9S/PteT5rAnH9er7zHReIOAeSyPb/2SJB1kPPUT2mVdZC
         bb1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=LK3eHapj;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor5681633pgi.75.2019.02.14.14.08.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:08:14 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=LK3eHapj;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mFDawymT8Zh+E+HOem14TYUCVAe8NsegNwIXcLtnH/8=;
        b=LK3eHapjO2duzbmPZyml2AAntHc+oCsXsAmOo3RruPUCgn4e1oQ/RTGL1IjLhTk3Bg
         nsUp4MloY69HY4JkvL/o6uZAwq4aEfit60aCwnjMcKT34tL5QSmuao5f11O7fVKsPoEl
         eBQ7udFASBf2anMqyQJJYRTOi7lKdktcnUwL2jrRxpmPMeq+iC8zXsWm18DW0z3287ZZ
         4e3Qvaw+WpYOYZ5V4As/0Clxq5EYE0ADKB8fcxTzUUenhmefNlMWkPMfBtlVeovTGLuk
         EWQcn87uG9Dm0/5kLzJc3zKogxuVgRNQ8mCciALhhT0nqhePF60DlU6Ayzh0Rt9pwrDh
         NTjA==
X-Google-Smtp-Source: AHgI3IbI/gzTIQORPKner8uMFyoO6LP7LhzVUUoaOAA5F4X4Rq3yTQfVTS2AgXHcjITlz8fbIPKOcw==
X-Received: by 2002:a65:47ca:: with SMTP id f10mr2034048pgs.166.1550182094094;
        Thu, 14 Feb 2019 14:08:14 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.45])
        by smtp.gmail.com with ESMTPSA id z62sm8443131pfi.4.2019.02.14.14.08.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 14:08:13 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 4FF443008A8; Fri, 15 Feb 2019 01:08:10 +0300 (+03)
Date: Fri, 15 Feb 2019 01:08:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214220810.cs2ecomtrqc6m2ap@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214211757.GE12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214211757.GE12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 01:17:57PM -0800, Matthew Wilcox wrote:
> On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> >  - migrate_page_move_mapping() has to be converted too.
> 
> I think that's as simple as:
> 
> +++ b/mm/migrate.c
> @@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  
>                 for (i = 1; i < HPAGE_PMD_NR; i++) {
>                         xas_next(&xas);
> -                       xas_store(&xas, newpage + i);
> +                       xas_store(&xas, newpage);
>                 }
>         }
>  
> 
> or do you see something else I missed?

Looks right to me.

BTW, maybe some add syntax sugar from XArray side?

Replace the loop and xas_store() before it with:

		xas_fill(&xas, newpage, 1UL << compound_order(newpage));

or something similar?

-- 
 Kirill A. Shutemov

