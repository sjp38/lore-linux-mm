Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D20EC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0162173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0162173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50F018E0005; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494A78E0004; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3108C8E0005; Tue, 12 Mar 2019 18:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F13568E0004
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:50:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o56so86208qto.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q/gNmAWrzs3R3AKUSeBmI8GJPMsyk64HzJV/VfrkcBU=;
        b=ZJTB4PoMwoYZO8s9CXfBRKKxrLwOUKJajeD9p4xsDvQ2oKSxGtOw61qXvuVAlTpBfU
         EsECJzhpULYM+klDnnp8d+C7rl4HJ+koimR36ro0NEulaLmHsxybWXUoe6uHolFUC+C8
         kspT2cV0i+wazDrvKw2xZgcvxWU4LNjd1SJoDH3ZYsLwS6xlVFrRsy9YgJcGywg/Ne74
         Ss7sTXG8NK8+rNTec4bqsI8NdL8lcZshBUQQV1tV6NtyFMcE2uBvyf5FqIzKSgWe6TN/
         hLVhVPerryFDsk3xuR7NPDS1AsgYf63phBurHtkz6iCUho6B3+y1tC8K/XJUIp7aYbjy
         wWpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVbQNuqe41PJVZTgdinML3X/bJWMlzIylneQrehczwzkCfsTqeg
	hv6bDwv3ezpBzy7dHmMTPUFOQy1hW1/3g0fBT9z/q7JbpWd+a9EReQ/27selBB5YeoFQzWBY9YL
	wNw2ZuL/7+H4ypq0UNXMDu5W/WcgwwHpHYofzxYuMyz1zOH8gpxtRIBkx8y9wJy+5xA==
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr8368595qta.272.1552431038732;
        Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGcEKeNZa2bEBw06KSKIqk/xbm5o/x/r6gJJRmWCslNtZeTQtIgC6tUyxV0bNUD5K///gK
X-Received: by 2002:ac8:2deb:: with SMTP id q40mr8368566qta.272.1552431038045;
        Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552431038; cv=none;
        d=google.com; s=arc-20160816;
        b=J35GOKOyCQmNDUC9hpIn9UrpRUvI5I2/uul4/6MR6/GIwrygTGOb8S6d0y/72QvLUQ
         nBUwwXJHMNAVpm8GNr6dKHSpEPy6onfWw9qf5qU6QK2IlDnjoP+F236I3Kxn0h4wbtuS
         gRM8mYCsfRBFHy3FgkyF8egRgpRhqinvpPEN8vi8URWcyHQC5FlTUaw9GgO7CepXTANy
         s9F3xkUGkiMOvlknXlKU8Koo+f0gG0BeF8z1mg9c/eq9Nl4SWEdUs5BDuEOBe4KqLut3
         A7IC3l7tVfa/omsWPXtFLfA3DmktlPda3Nhs+Dlebdt0DcNtMjK/xSxcJs9Aibjf5cTO
         yJKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q/gNmAWrzs3R3AKUSeBmI8GJPMsyk64HzJV/VfrkcBU=;
        b=YbbApEFMN9HTVHdJDIkZydkvij+VAaKADZUR0lURxOqChl6D2sU5HGeHSZQPIA7qRG
         1UhTnPMZvCvGXrkw146HGJeg0YNVJCQOr6ETvft+DTW+A11XWWNvL9kY1WooKWgA3qcU
         OSSuVKbQZY6DnvHexr2zN7t8ws86FnlKc7BkoclKlaCUZEVFjk3dconrJ0xO6DbTGX1+
         K/PozoZvHtIEzoY9hO8JQ0a9rUO/dyq1QKEdMylZS8/QJDfeBvrI14YG2dSINJJb8DBx
         tJYLQiL3TXSjzyQmNIRZ4gmI8PGygCwrNmtDB1XPSeJX0n7YrLbXM5LZWRQWg9r3zzzS
         140w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v124si1546005qki.149.2019.03.12.15.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:50:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 25A1C3086201;
	Tue, 12 Mar 2019 22:50:37 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DFABE19C4F;
	Tue, 12 Mar 2019 22:50:32 +0000 (UTC)
Date: Tue, 12 Mar 2019 18:50:32 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190312225032.GD25147@redhat.com>
References: <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
 <20190312211117.GB25147@redhat.com>
 <1552425555.14432.14.camel@HansenPartnership.com>
 <20190312215321.GC25147@redhat.com>
 <1552428174.14432.39.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552428174.14432.39.camel@HansenPartnership.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 12 Mar 2019 22:50:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 03:02:54PM -0700, James Bottomley wrote:
> I'm sure there must be workarounds elsewhere in the other arch code
> otherwise things like this, which appear all over drivers/, wouldn't
> work:
> 
> drivers/scsi/isci/request.c:1430
> 
> 	kaddr = kmap_atomic(page);
> 	memcpy(kaddr + sg->offset, src_addr, copy_len);
> 	kunmap_atomic(kaddr);
> 

Are you sure "page" is an userland page with an alias address?

	sg->page_link = (unsigned long)virt_to_page(addr);

page_link seems to point to kernel memory.

I found an apparent solution like parisc on arm 32bit:

void __kunmap_atomic(void *kvaddr)
{
	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
	int idx, type;

	if (kvaddr >= (void *)FIXADDR_START) {
		type = kmap_atomic_idx();
		idx = FIX_KMAP_BEGIN + type + KM_TYPE_NR * smp_processor_id();

		if (cache_is_vivt())
			__cpuc_flush_dcache_area((void *)vaddr, PAGE_SIZE);

However on arm 64bit kunmap_atomic is not implemented at all and other
32bit implementations don't do it, for example sparc seems to do the
cache flush too if the kernel is built with CONFIG_DEBUG_HIGHMEM
(which makes the flushing conditional to the debug option).

The kunmap_atomic where fixmap is used, is flushing the tlb lazily so
even on 32bit you can't even be sure if there was a tlb flush for each
single page you unmapped, so it's hard to see how the above can work
safe, is "page" would have been an userland page mapped with aliased
CPU cache.

> the sequence dirties the kernel virtual address but doesn't flush
> before doing kunmap.  There are hundreds of other examples which is why
> I think adding flush_kernel_dcache_page() is an already lost cause.

In lots of cases kmap is needed to just modify kernel memory not to
modify userland memory (where get/put_user is more commonly used
instead..), there's no cache aliasing in such case.

> Actually copy_user_page() is unused in the main kernel.  The big
> problem is copy_user_highpage() but that's mostly highly optimised by
> the VIPT architectures (in other words you can fiddle with kmap without
> impacting it).

copy_user_page is not unused, it's called precisely by
copy_user_highpage, which is why the cache flushes are done inside
copy_user_page.

static inline void copy_user_highpage(struct page *to, struct page *from,
	unsigned long vaddr, struct vm_area_struct *vma)
{
	char *vfrom, *vto;

	vfrom = kmap_atomic(from);
	vto = kmap_atomic(to);
	copy_user_page(vto, vfrom, vaddr, to);
	kunmap_atomic(vto);
	kunmap_atomic(vfrom);
}

