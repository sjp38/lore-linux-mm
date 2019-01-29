Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B34CC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:52:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2077420882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:52:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2077420882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0C338E0002; Tue, 29 Jan 2019 17:52:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABB138E0001; Tue, 29 Jan 2019 17:52:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1638E0002; Tue, 29 Jan 2019 17:52:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 557078E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:52:56 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so14916752pgb.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:52:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lzafb5HEhSp1SvuqZN9W1QfMlYhCd9ZnKkB9ve3t/oY=;
        b=FiWZe8xKxq0zpNE9wAtfVJuBpI8vbSkeMUMjM+R+I59GBlXt9zmB0JYj3eff6iQtvV
         Jg7j8qUaCka8sG6lpmdxodHPCyNfRz0bMEEF+ItT0VUJCFRi465BGB487bkpTWJ6xyt5
         t/TkFCsG7dRCKCm1gJxHtEcJ4oVUIlRFoWQ4iE94LtOpL2aHgpBGT7A054VuE4Kk541l
         8lr4oGU40e3f6D7291nQ79QwPZzqE86ttuZwgVI092DFLDdEoXakTTSWGACDliLwfyo6
         Pzw6Y+gl33QWPq0icUyowuadSrw+GcB2aMfIy+zRimkkL4tKy2/1sNHU4GvcTpogDpS/
         QSng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeDggpoOgaXbs6F8tJ0CE5IezUd8QIzb5lE4v6ykTbzN/pcq7wy
	q69ayMaEwlsEHYWyJKc+OFRc3GInFb+OBAu1WrmJNs9pvzeA8EOj3alczrQODvis5T0EWZVSWYz
	y2+64oLAqgeQoghf4Mh+ryE/uIEmibbVTqluHVXMeJpI00sqrR3HLetv51vdw+7i1Ug==
X-Received: by 2002:a17:902:7201:: with SMTP id ba1mr27751001plb.105.1548802375915;
        Tue, 29 Jan 2019 14:52:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Ycl1wwt0T70FYG1EdyycOhSXRevDLBb/OSrCAx+NYHg/QUS/yjPuHGiaPSr+yCr0IbtG3
X-Received: by 2002:a17:902:7201:: with SMTP id ba1mr27750973plb.105.1548802375158;
        Tue, 29 Jan 2019 14:52:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548802375; cv=none;
        d=google.com; s=arc-20160816;
        b=Oegmtzme6d2JGjHjV+7mztYKqZAvrr09OFetwnJJcCO9ocqUd55w7k5zGz3KCyAA4F
         rJl5W03VbgvmzZtVQiyKuDi+sPu/pWtoNxgZ6ol7u24Ggpbp1oWd5dpNcG7LVwI6DosD
         7DoO8EOo6vfiGiG3TI8ZMih8HoT0dUiVKRiZnpiHHLWFhATCuy3tkfraUemuB/3vFJkU
         mZw2NdMTlwlO/CQPPnhR7ZjbJfa9r8h96kaGD3kzTukYse7yVl0qHgj45jhbCsgLm6ya
         rw35xeiKy6VJrOubnjd2Gy6sFucS6zX8FIwBjFIru0FNNB+wIWScK7zUp8KLwz1rZ64X
         hFGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=lzafb5HEhSp1SvuqZN9W1QfMlYhCd9ZnKkB9ve3t/oY=;
        b=LozIMJGLdWV+NzDsLbgOuZ0EOBn9JyvDPoXaNQLUovPbW2OKMOXdBW7cj7y0QjZOA0
         22BnZfx9IvOh4S9qE0EJV4zGUahIYBLmXl9iOkdswvYLCHmNle7LWCWAEf1VAgFMKgOI
         zDSJ0d1IAJfcQo64J2VugcSrgcoXy+4NPP125ktXH9mC/dYs4HgQk1Jmqi1cHLVKi/WP
         g5vYI5SlB3zY9RTv1D/Hc+UBiW+Z+q2HqLRzR+HjTvc0u5UYMUG3xpxajJcmSstGLQWn
         Pb4KPoa2U28gkCp0LP9bpq6IE7zVxmAoh2xxJmAtKJmcFi90qfVZCJdjOehP5tm2PazQ
         llig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y189si37686578pfg.75.2019.01.29.14.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 14:52:55 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 8B9F834A2;
	Tue, 29 Jan 2019 22:52:54 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:52:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
 David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli
 <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 1/4] mm/cma: Add PF flag to force non cma alloc
Message-Id: <20190129145253.8ac345bf7ca6e66cf08bd985@linux-foundation.org>
In-Reply-To: <20190114095438.32470-2-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
	<20190114095438.32470-2-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2019 15:24:33 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> This patch adds PF_MEMALLOC_NOCMA which make sure any allocation in that context
> is marked non-movable and hence cannot be satisfied by CMA region.
> 
> This is useful with get_user_pages_longterm where we want to take a page pin by
> migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
> that we avoid unnecessary page migration later.
> 
> ...
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1406,6 +1406,7 @@ extern struct pid *cad_pid;
>  #define PF_RANDOMIZE		0x00400000	/* Randomize virtual address space */
>  #define PF_SWAPWRITE		0x00800000	/* Allowed to write to swap */
>  #define PF_MEMSTALL		0x01000000	/* Stalled due to lack of memory */
> +#define PF_MEMALLOC_NOCMA	0x02000000	/* All allocation request will have _GFP_MOVABLE cleared */
>  #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
>  #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
>  #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */

This flag has been taken by PF_UMH so I moved it to 0x10000000.

And we have now run out of PF_ flags.

