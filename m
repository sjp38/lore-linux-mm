Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DDE0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A05D2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:51:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A05D2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B72958E0004; Mon, 11 Mar 2019 23:51:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B220D8E0002; Mon, 11 Mar 2019 23:51:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12AE8E0004; Mon, 11 Mar 2019 23:51:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 787708E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:51:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k5so1136331qte.0
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:51:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=q5OtFmBn4kunq3TRH7QETyZ6fOkGOBD8DRouuexq1Q0=;
        b=Lp40S3CPIVULVjspZlEMTaxTAGopMBzfTj4WxV4fS6QixIm96ho8eH4fnKlYENEXQC
         lnqTPvaAgAh72f1IwAl0IrVifGBOfYqoDLVq6gqdAbamt/ae3RyyOzs3wRMkJ1C58CDt
         7AGIl334+QLsCD6zb+bFUSxsrbRWkesHBhd30Tw8WDBmunUXZ4EEbc5bkNodnbqOP0Yy
         02eZWFWZ3YhRjwTAC4RAJWfB0pvU0S/DfvLoxk6cKJjkCwnYRLHtbR6Wx6hxb/SaR4fs
         QO4na5+YxrbYZM5vDqhsBPBt+OiT6XaJTBlsxKbB0jbNRz+R6ADwklH/6C0StssBxsya
         G1JQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUxg2aLbVR/iAEETJx2LnHTFUzTfFXkIQzS26q7D+T1ujw379o/
	9CrHJwIJB1Jh9kBa5NNTIiY83zkmseHdFrzx2Zdl1EFmERxUfD1lz9cpSTgWEphJJgWj+axuNQV
	n/1Fczx5KL0ER9A3PqmWUQpgBusEXuhOHQNg6NHlbjOnf2opUToQhw0oATYIFb/ZNwQ8BSpyqUk
	OOTM5BRYZUOHBD4Qb8l0vl8TTF3pWnXCQuvC5DT/emVzjS8cSMW0vfzmZnXfmQT/3uJepRqxXPv
	kSPvhJACENBuwEccHO0VS96zsajIdaTtAEItkKB80iiTA0xSCYRXqx0AkIq1mSH3jPyX1kis8a7
	IvxfJgcnqDBqeVlOTX20yB5KStZyyHCvM8gzyygbDO1CA3VsA6lnZv3mLbmoOZtUsz8q8gx9k89
	N
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr4614629qta.272.1552362689307;
        Mon, 11 Mar 2019 20:51:29 -0700 (PDT)
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr4614602qta.272.1552362688621;
        Mon, 11 Mar 2019 20:51:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552362688; cv=none;
        d=google.com; s=arc-20160816;
        b=ZS1c5Rys6iVwwE6YXHFEKjB1VXv8Nn9IgGDjVf2An55QpK22SKWh13Zg6kR+pJosFr
         FIIlJoAvwT3K0jzVoSlXdAaeIlbbGTNBJ0muWZiTBnNvStOial80WB2pM6GiMJCpcQJX
         RC7nY9Wkuc3kPdPrRA8JpcmcQBEctjxftqBdlC7OCeysz/+zuuNM/Mb1XXdm8eu0DP+S
         N6RMOywS21L+7BqqWM9wJA69/+FVtip7s8NfnxPKHcw6JgeF0Ohf/F3cMWKdJHwfhlL0
         /pfT3buLECU/oqNCqMo0EEVyND6zL2NWM4v+ffGUnTmoWEgH6pUHQr98sz55iO/UVGtF
         k5uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=q5OtFmBn4kunq3TRH7QETyZ6fOkGOBD8DRouuexq1Q0=;
        b=YnQRKfNu6LHhtXI7C11P54i+rLFBdWX5Y/p2MkdJ0Q6Rw8ZOIZSMNstTDx5BZFNyqw
         9kxfiTmKckXzpNVT7Ol3ePdGF28aoAohgSlP/r+cspl+jZQZ0fMztRBZj3U09wFgSdom
         NGO3Muf+/sFzsF3AGkQ9OhYYN/AoZUZTqnfte3e/89VOPtegCUXnb0I9bugRVCB7Bxxd
         HLjxOXUSYcPN5CvoAiiYBd9qRfb5lmr4Kzg8qnVpYeXvvfaCILub2JRkX1DWm4rk4fPA
         TeggvKB2BHVb/HdK6X4WbaPHcHwQJ7c5WeBAYplALkv35orbUKbPPRZOvWPS+pvPnG8g
         2feA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6sor4360912qtq.2.2019.03.11.20.51.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:51:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxm42I862OWQ7Skwz8qnWa/npKwc8mf8yAY+hqDoxpxxcCijWFoKhk0VDEIQ+MmxQonZIJ2AQ==
X-Received: by 2002:aed:3f81:: with SMTP id s1mr26463323qth.94.1552362688407;
        Mon, 11 Mar 2019 20:51:28 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id j139sm4250733qke.26.2019.03.11.20.51.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 20:51:27 -0700 (PDT)
Date: Mon, 11 Mar 2019 23:51:25 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190311235100-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
 <20190311084525-mutt-send-email-mst@kernel.org>
 <20190311134305.GC23321@redhat.com>
 <4979eed5-9e3f-5ee0-f4f4-1a5e2a839b21@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4979eed5-9e3f-5ee0-f4f4-1a5e2a839b21@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:56:20AM +0800, Jason Wang wrote:
> 
> On 2019/3/11 下午9:43, Andrea Arcangeli wrote:
> > On Mon, Mar 11, 2019 at 08:48:37AM -0400, Michael S. Tsirkin wrote:
> > > Using copyXuser is better I guess.
> > It certainly would be faster there, but I don't think it's needed if
> > that would be the only use case left that justifies supporting two
> > different models. On small 32bit systems with little RAM kmap won't
> > perform measurably different on 32bit or 64bit systems. If the 32bit
> > host has a lot of ram it all gets slow anyway at accessing RAM above
> > the direct mapping, if compared to 64bit host kernels, it's not just
> > an issue for vhost + mmu notifier + kmap and the best way to optimize
> > things is to run 64bit host kernels.
> > 
> > Like Christoph pointed out, the main use case for retaining the
> > copy-user model would be CPUs with virtually indexed not physically
> > tagged data caches (they'll still suffer from the spectre-v1 fix,
> > although I exclude they have to suffer the SMAP
> > slowdown/feature). Those may require some additional flushing than the
> > current copy-user model requires.
> > 
> > As a rule of thumb any arch where copy_user_page doesn't define as
> > copy_page will require some additional cache flushing after the
> > kmap. Supposedly with vmap, the vmap layer should have taken care of
> > that (I didn't verify that yet).
> 
> 
> vmap_page_range()/free_unmap_vmap_area() will call
> fluch_cache_vmap()/flush_cache_vunmap(). So vmap layer should be ok.
> 
> Thanks

You only unmap from mmu notifier though.
You don't do it after any access.

> 
> > 
> > There are some accessories like copy_to_user_page()
> > copy_from_user_page() that could work and obviously defines to raw
> > memcpy on x86 (the main cons is they don't provide word granular
> > access) and at least on sparc they're tailored to ptrace assumptions
> > so then we'd need to evaluate what happens if this is used outside of
> > ptrace context. kmap has been used generally either to access whole
> > pages (i.e. copy_user_page), so ptrace may actually be the only use
> > case with subpage granularity access.
> > 
> > #define copy_to_user_page(vma, page, vaddr, dst, src, len)		\
> > 	do {								\
> > 		flush_cache_page(vma, vaddr, page_to_pfn(page));	\
> > 		memcpy(dst, src, len);					\
> > 		flush_ptrace_access(vma, page, vaddr, src, len, 0);	\
> > 	} while (0)
> > 
> > So I wouldn't rule out the need for a dual model, until we solve how
> > to run this stable on non-x86 arches with not physically tagged
> > caches.
> > 
> > Thanks,
> > Andrea

