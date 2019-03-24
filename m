Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DEE6C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 15:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C48C20830
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 15:42:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ovmZ8RD3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C48C20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0BBC6B0003; Sun, 24 Mar 2019 11:42:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB9756B0006; Sun, 24 Mar 2019 11:42:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA8766B0007; Sun, 24 Mar 2019 11:42:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 866476B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 11:42:26 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v2so6522914qkf.21
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 08:42:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eR//r5COe0kfcFPHpHjuqOueAtDRvGp3dFXoKApE5Pw=;
        b=rcDNkf1ADT5oNH0Baxhi+/azG42z/ulsX1lfU9i26jRYI+bJpa/Kg/dvAj2LqQDSqs
         qQxJ7du1Auz1EYDCSGwrfw/RTng/gri708asoBdKgg+xrAg6i1plA7mptoJcLOctvssd
         Peoy1jMJjQhUCKM6WjSJMXvhcTKGtjESGgnZCBt3V/ebJ6OVR/qysFfzz4Yzq2Zd+T25
         axJ19k24MCwvxUvviWlDksQSW97lbkroLTs6gnsqd31GqNj5p/VWurseFN4MDgQII0ET
         brMUZkmxZotj7ksguyN6seAA8hgJ29G8VqvGUldd0ITfEeUXrBXzs4RrcFsJzVC9l0wa
         oCBA==
X-Gm-Message-State: APjAAAXPnLqLome5reuIvqjJpaF6WhslGBwb4hgrKJE7rUBfYTSDf99H
	H+daOkGd3MQ1SA7lYXouSfaVcyuvSGMFGjA3Vpo7ItVYAwv60qWhWIHid1Jy3Q1SmX4Z2jIrAEu
	R8pNh5CeC6/idM7qd2KMLBp643JVUv7IyrfzSOnH+/h811A1OEBumGj92f3Aw3Seg7g==
X-Received: by 2002:a37:e40e:: with SMTP id y14mr14977220qkf.232.1553442146201;
        Sun, 24 Mar 2019 08:42:26 -0700 (PDT)
X-Received: by 2002:a37:e40e:: with SMTP id y14mr14977182qkf.232.1553442145446;
        Sun, 24 Mar 2019 08:42:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553442145; cv=none;
        d=google.com; s=arc-20160816;
        b=rDXWLdTkfD+3euYrlQpFyBxqdYCD802iTrVi0TTgArBXOZ462vtQCvNKQ8ukM5EACa
         GqVFFcHyPRgfURC1HswoBRZLwFQc7NWRq3SACq6yv2mgEcrscFHroMXHMTlCKQxAu8WU
         TWhxfJI3dKnBkZ60a7O6yzy+A7zYTE+iV01l9+8sJmTTE5QCX0NUkQr8FDTtyoF46eDF
         OqiWS4uB6PKIIbX4VLOdNCVa7MSVSptp5CumZnQbN6VNU8Lgu53eU/TBj/sVllO+5JYs
         7rDsXJL/O+IfWKBPyk/PFLoYCRayX9Y1GKn2eb5FvDq4ZZBUK18rCaWZDahWdzGfKvB3
         hmLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=eR//r5COe0kfcFPHpHjuqOueAtDRvGp3dFXoKApE5Pw=;
        b=sP1Fa8ZidvVjj/9QRlwH1P8irGpnt09Pa6ChmhczWeZUhJr7fmUvL69mPqzQegqN93
         zhNciica9zjwbsrNzB2+xljZWhaJ/TL4o09fPsRpULJIKdwcyvZh2aLqVRkcX+Rljfs8
         hTAobXEEwbBrTN7EJi8F8iYgTR6Md4Y/K4GkPaYJzRHeMZeCDxFYQzsctbJO2lu6q3IA
         ty8pL+aJNd4yMbm+QywiB9HaQ6mwPH3oyPi8voFAXloehHJjqUFvIcDpD5oac9F0Ng8R
         cuGtq3OKlXT6/6QShNNN6g+fKoGhceRXYwYeq1UY8EdzsOnVY7ngOhQ0ZqSlM16B/G2s
         +jpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ovmZ8RD3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c5sor9376744qkb.109.2019.03.24.08.42.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Mar 2019 08:42:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ovmZ8RD3;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=eR//r5COe0kfcFPHpHjuqOueAtDRvGp3dFXoKApE5Pw=;
        b=ovmZ8RD3v9Ry7SDtrBdbiROVF51TT+ZhuuqPSfUko+qQs3gCZoPA5EtpYw/gAEDxG5
         yesIuHpFfgwpRB08wAJ8ELtRBfBcjo6IvvAbn1Uvr979IqhdxZak7O9pvHbfx3Jo2yTo
         6zT28EqqgpFOW/H/EkpG9vzXAAMqB1JGhJgFMP2iTGYQ19b3QOpQSaizp6DhXT22mwGK
         kwQcOjDcdhxEbE3hHdntGU7OPz1yqut//wJOcYV5mnTLmNojHz1c8a4ko5+AORtGxGn7
         W0MDo8LcHRPYS3go0MAy+wj8gn2dzISCtQ4Wc4dC7MISchKHTwUbBhMoxgpo0I7E4f6i
         0DOw==
X-Google-Smtp-Source: APXvYqw7Pci4YTJFLt1I1KNpeacgOl7cPhPVIWnmCvQ0fFiecbw8hxGeVGzUtJ5XZXfaGjfzXFlGSA==
X-Received: by 2002:a37:9d84:: with SMTP id g126mr10364680qke.22.1553442144922;
        Sun, 24 Mar 2019 08:42:24 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id c12sm8254899qkb.86.2019.03.24.08.42.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 08:42:24 -0700 (PDT)
Subject: Re: page cache: Store only head pages in i_pages
To: Matthew Wilcox <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <0d7ae84f-268a-aefc-ee01-5db9b7327c8e@lca.pw>
Date: Sun, 24 Mar 2019 11:42:23 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190324030422.GE10344@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/23/19 11:04 PM, Matthew Wilcox wrote:
> The patch for you should have looked like this:
> 
> @@ -335,11 +335,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>  
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
> +       unsigned long index = page_index(page);
> +
>         VM_BUG_ON_PAGE(PageTail(page), page);
> -       VM_BUG_ON_PAGE(page->index > offset, page);
> -       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> -                       page);
> -       return page - page->index + offset;
> +       VM_BUG_ON_PAGE(index > offset, page);
> +       VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> +       return page - index + offset;
>  }

It works great.

