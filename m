Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D65AC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 01:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A0AD206BA
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 01:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S2991DI3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A0AD206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C62056B0003; Mon, 25 Mar 2019 21:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE9F86B0006; Mon, 25 Mar 2019 21:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8B946B0007; Mon, 25 Mar 2019 21:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6DA6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 21:59:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b11so10938991pfo.15
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tH7vupbA4qCrC0XFe2q1QYzpniBMj5XaFeIPW4wHzjo=;
        b=YqA7baKH5p4qh8PVuIHRjMdj7z2KiYuxvtPnSzNb/pone/RpxTLK7MNy1Jf5G3Ut+e
         zwp4zukkANpg4nMt6k8ze1atsAcCPJgPjN36uy01UJ0xoaVAN5s66deHTHkrbZLWiW1b
         kXN/YtAoTiRykwHQiX5vkRyw/dpujmMFOCfyjpdCtqC48utjUNsAHAjoXiAQvmLWq9sV
         UoVhc86Ate+ood0BSNrr71M6uvwEvwLO/2MgsHyjp4p5+KGKHcePEI1QFTkpEez9CNKp
         ZkDBfILxWHRkDeNBmgXu6a28OAu0QI1jQLkxW2UIsc0VN3NydUQpw8lGc5CFKxY3e+AE
         +s+w==
X-Gm-Message-State: APjAAAUaYkBg+mgSt2w+2u+2kwYjCAHSGZeVjzwhvQIi/uma9bTimmxs
	ErX8uMvtuVPmD8ZNRwCgKX2hNacHcacVqTQzioJoYf8lxRDD6a7uJ2E3t9OBP0A6Mod5nLPjkNT
	MAmMPDrAI8Lx8Yt55T16uoHXda5+WbrN9c96ec03a8NCKnOLoMWxFxdzqu+qmXTIbDA==
X-Received: by 2002:aa7:8d42:: with SMTP id s2mr27281090pfe.116.1553565580047;
        Mon, 25 Mar 2019 18:59:40 -0700 (PDT)
X-Received: by 2002:aa7:8d42:: with SMTP id s2mr27281033pfe.116.1553565579117;
        Mon, 25 Mar 2019 18:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553565579; cv=none;
        d=google.com; s=arc-20160816;
        b=mVI7T9t9ANNNPQ2mIJfqN8vOa3nCDO+gC2nH7HG0yHOfAkQkhj3CGx/FEXYHL0Kizj
         x521M6RiRKz3kGXhOkh1xGUeayt0sOCxVFz/NmBLbNuZhN3hkU4FQy9/dkY9xkZpQuMp
         3p8Y2U4tdDIIGDhH4gmV+CrDO3dEuk40NclMctiQ4/zWSLlqmsVkcDI8r4UWYJTFv4yp
         50thazimj5IyS4oZoWPi2Juu1sV/G1cbzsc6IytOy64NUq5/+EktKV3oxoAMRjaFEvNq
         VwgVT5RSplnwmbp8KD2ihn78IB6kjIan24c+o0/I0So/kWI5n2n/DV5N+SXUoXe5zLRe
         kOoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tH7vupbA4qCrC0XFe2q1QYzpniBMj5XaFeIPW4wHzjo=;
        b=Li3Zq+xkXZ1LHwaj7eeFferNgmWBvMx95qtiryatT4YqmwCSRybjtTZmB18e1ZOk2o
         ZJdZqtIrkKe+l4bKP1HLxkbWKYtYRyLqGoTiNvf4fLKcW9w5oCSgGotZl6L7danxrBzP
         JZYqQgYYRjAY6yQ95tX6s3f+IAoQfYGoWaM657zKvWC/KOpvHRRCkBlOUaPbXTKXmQnr
         FyCd2tS4mpXpKd4dd5f4Nx6nVqFRgVW82qdj8Pv68Cuqm9kBlMmY+uwGjxuQgcSO7gm9
         VcDfkEOy1jgfbKvLpTLtf9oyUZJKisXl+w0U1MbljQSCQZsE1w1MzjphshGxRaIluyp3
         o8CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S2991DI3;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j31sor18621230pgb.10.2019.03.25.18.59.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 18:59:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S2991DI3;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=tH7vupbA4qCrC0XFe2q1QYzpniBMj5XaFeIPW4wHzjo=;
        b=S2991DI3D741BudXvMXJRAwbOrj4Z83KFTqs5TWZPteSrwwReMpFVng4y24q+dSUes
         vjjfQtRsUyaP3VFPW5MMYWFVibXWk5s9h3lUWg9qii0zvkeoU2WIdfr6PMLX21SJ6FKr
         IJvQqc06yD169oUFkvxPvHRZ9xKBJUs7awpJFBtoYjLexj0ipv0XnMuxEasiqph7x96Y
         EcbSrjimxNsfrZ0kVHFusa/aSreBsWoxw4/0P0oVWulfAAXCZv7RKkk1nsvm/sUP6Hmf
         VV6Bo5chLxRmuo+NJNrEFhEkbFP1R4RswqSYNHCEur2sF/eiJtx4fAblWNxqEmm0CVij
         iMfw==
X-Google-Smtp-Source: APXvYqwrBF88ljyPW3w05C/Hsm0RBcZX0sFAnuOFs7ZWUcueCH++wfcp0HI4+jQwCpsLdRyzpAMZoA==
X-Received: by 2002:a63:4b0a:: with SMTP id y10mr26304521pga.66.1553565578594;
        Mon, 25 Mar 2019 18:59:38 -0700 (PDT)
Received: from localhost ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id u86sm39516753pfj.69.2019.03.25.18.59.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Mar 2019 18:59:38 -0700 (PDT)
Date: Tue, 26 Mar 2019 09:59:25 +0800
From: Yue Hu <zbestahu@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: iamjoonsoo.kim@lge.com, labbott@redhat.com, rppt@linux.vnet.ibm.com,
 rdunlap@infradead.org, linux-mm@kvack.org, huyue2@yulong.com, Anshuman
 Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm/cma: Fix crash on CMA allocation if bitmap
 allocation fails
Message-ID: <20190326095925.0000186d.zbestahu@gmail.com>
In-Reply-To: <20190325151541.15350b039239ee9b331f3922@linux-foundation.org>
References: <20190325081309.6004-1-zbestahu@gmail.com>
	<20190325151541.15350b039239ee9b331f3922@linux-foundation.org>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Mar 2019 15:15:41 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 25 Mar 2019 16:13:09 +0800 Yue Hu <zbestahu@gmail.com> wrote:
> 
> > From: Yue Hu <huyue2@yulong.com>
> > 
> > A previous commit f022d8cb7ec7 ("mm: cma: Don't crash on allocation
> > if CMA area can't be activated") fixes the crash issue when activation
> > fails via setting cma->count as 0, same logic exists if bitmap
> > allocation fails.
> > 
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
> >  
> >  	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> >  
> > -	if (!cma->bitmap)
> > +	if (!cma->bitmap) {
> > +		cma->count = 0;
> >  		return -ENOMEM;
> > +	}
> >  
> >  	WARN_ON_ONCE(!pfn_valid(pfn));
> >  	zone = page_zone(pfn_to_page(pfn));  
> 
> I'm unsure whether this is needed.
> 
> kmalloc() within __init code is generally considered to be a "can't
> fail".
> 
> If this was the only issue then I guess I'd take the patch if only for
> documentation/clarity purposes.  But cma_areas[] is in bss and is
> guaranteed to be all-zeroes, so I suspect this bug is a can't-happen. 

However, firstly cma->count will be assigned to size >> PAGE_SHIFT in
cma_init_reserved_mem().

> And we could revert f022d8cb7ec7 if we could be bothered (I can't).
> 
> 

