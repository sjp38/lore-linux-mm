Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41FFFC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D318021473
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:23:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZDeN3RZm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D318021473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26D886B0003; Wed, 22 May 2019 16:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21DF96B0006; Wed, 22 May 2019 16:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D4E6B0007; Wed, 22 May 2019 16:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBE146B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:23:24 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so2311696pgo.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 13:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OR/F32T2HsRarig/yfUZBtfPy41fvhI2UBxZTDwWsVo=;
        b=Ae7hsm7ydqzsjjo5RxEjZA1rMe2Df7M6FaWe0CKtn/+uuLTALdEe3o6mCbERAlwNlh
         he8/XrWktfiKqckZ2NU67TnoAu5/HX0xxjwvc42FlGFrTwicY0hzffpZ6Eh5rMJX7B6z
         zADjTvC3uwjwl8wD3R5dBPT+L4LxVzpap0N/h9bA1k0WWUNBOy3YkuGbTtMF/n1RS641
         Q9aP6/optiqeH2JCdo9PkMYtU9EqeLgTJ7tLMqK14Xw39JDr10b0kmavBfHlK0lbnoPV
         4yRbKlEoVkiDW3wtobVJ0jA+pTIk4LSvu/uaiMAz4WJpZN1rVZsqQ+iclw3tbZjOkur0
         QsTQ==
X-Gm-Message-State: APjAAAUpildijxe+0yB3NhvVeWUel+JYoCNZn7AC6QUkpi4i3eYymSCH
	yjAXS21nYA3+8ym4wuXRC5ipOjaI+ET6NJ4H6NanOVKT/MRbR47SqxNPXo/jO8PYhjc9N487MmR
	YWRQHGW65nIdsDk8Gks4dGr9bsSft6J5tuviAKa/cSrTBc838WwtefTODyteMvciRiA==
X-Received: by 2002:a62:d205:: with SMTP id c5mr97058926pfg.219.1558556604406;
        Wed, 22 May 2019 13:23:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzykEfkizh4bN41+A8BDIQdyvN10I3goBDUtDUunjVZsVVjv357OVxabME7MC1zNoiQHHaQ
X-Received: by 2002:a62:d205:: with SMTP id c5mr97058875pfg.219.1558556603764;
        Wed, 22 May 2019 13:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558556603; cv=none;
        d=google.com; s=arc-20160816;
        b=IIiQbaH/isEdTyejZFhRr0Px+65o8TjlC52GdHC/7ynDBfmITkFJsGpihLw4FabdIJ
         DFDm0km5uhzuCrbOCYVBMj0ZL1w8fB+y5P2seXr68zHLun3tIqvW7PutqMVHDZU+17kB
         xD0WaFvtEj7BCM6A1rp6xob/SiacWJYHGCKaSgVIf2P+g93+26dntCsLO43uR2hSDYkW
         pi7yEqWi2hUofFF3SAvafPVqS1s3FWVN2zbriFgQExBJ6CrEa1znLRTj+dnGdr7m7fbT
         0S/eQ2jypGIDaD1hs5heUOrW+0fMHVNCMjSKLRB9w8HGW6Tkm4D7RRjtvA05WV0wKp7A
         Nv2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OR/F32T2HsRarig/yfUZBtfPy41fvhI2UBxZTDwWsVo=;
        b=VHS90ZRbX+e4ew1Lr/NEbzw8s0Zkf3Kiv1FRKAspcp8/Iu8DqxiTuoXKKXCIn22hNk
         PIjk/ZngG1SHOPUMc+8YU5V3U4E4OMUSgP63pnJXXbWvyb/tpdplE0QB3ZZNKr9tQWpT
         o8OWYKRtUu58csPATIXrZqh8tnydITqpPnEm8E5SzC5VGDdso9PBI9ziOTTYAckyvGfO
         mbvPDgN4gpCuHOZYt5hLrUhhf5cjp9E70MvLrTQvAnJbRtkQNrzYfnKwMK6artyIxXQJ
         lkY4+XIrEPWDB0gg6u3rHVeI/C2pgevnKcWcBWcO73xrQM3FBxtWLR25f00bmQOQjjn7
         lgZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZDeN3RZm;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i2si28023622pfb.7.2019.05.22.13.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 13:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZDeN3RZm;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3F0C020868;
	Wed, 22 May 2019 20:23:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558556603;
	bh=U+M6rf3AMmh/gfDRmie33m03JcslFeEpWHuYCbgXRdA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ZDeN3RZmrMOyzEPRBdj6EkpJxeuolU55ceZ8admENVimY9uWgB1XQ9yIbch4ihSWu
	 kHK9uVs+w3oSYlhP+MmVcu0WL++4CxRRaRq8UD16ho9NEZYiZoQXusbpMOpzpIfuRl
	 Kdkli/pLetz+4OJrGDoKGRN1fVyLkNhmNBBJky1s=
Date: Wed, 22 May 2019 13:23:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>
Subject: Re: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
Message-Id: <20190522132322.15605c8b344f46b31ea8233b@linux-foundation.org>
In-Reply-To: <20190522195151.GA23955@ziepe.ca>
References: <20190522195151.GA23955@ziepe.ca>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 19:51:55 +0000 Jason Gunthorpe <jgg@mellanox.com> wrote:

> gcc reports that several variables are defined but not used.
> 
> For the first hunk CONFIG_HUGETLB_PAGE the entire if block is already
> protected by pud_huge() which is forced to 0. None of the stuff under
> the ifdef causes compilation problems as it is already stubbed out in
> the header files.
> 
> For the second hunk the dummy huge_page_shift macro doesn't touch the
> argument, so just inline the argument.
> 
> ...
>
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -797,7 +797,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>  			return hmm_vma_walk_hole_(addr, end, fault,
>  						write_fault, walk);
>  
> -#ifdef CONFIG_HUGETLB_PAGE
>  		pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
>  		for (i = 0; i < npages; ++i, ++pfn) {
>  			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
> @@ -813,9 +812,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>  		}
>  		hmm_vma_walk->last = end;
>  		return 0;
> -#else
> -		return -EINVAL;
> -#endif
>  	}

Fair enough.

>  	split_huge_pud(walk->vma, pudp, addr);
> @@ -1024,9 +1020,8 @@ long hmm_range_snapshot(struct hmm_range *range)
>  			return -EFAULT;
>  
>  		if (is_vm_hugetlb_page(vma)) {
> -			struct hstate *h = hstate_vma(vma);
> -
> -			if (huge_page_shift(h) != range->page_shift &&
> +			if (huge_page_shift(hstate_vma(vma)) !=
> +				    range->page_shift &&
>  			    range->page_shift != PAGE_SHIFT)
>  				return -EINVAL;

Also fair enough.  But why the heck is huge_page_shift() a macro?  We
keep doing that and it bites so often :(

