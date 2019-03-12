Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A80F8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 615DC217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:57:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="TOJYB90P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 615DC217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40EE8E0003; Tue, 12 Mar 2019 18:57:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF0988E0002; Tue, 12 Mar 2019 18:57:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDFAF8E0003; Tue, 12 Mar 2019 18:57:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B77678E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:57:21 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b6so5471284ywd.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=5vFP26CUQPLhQhavIv7KLQW+HvC8lzvQsktord7sqXU=;
        b=dPSOiXIZmcuvQfcK69Y2yB/5Ozg6VU5zF/pAt2dVBqPfUS907hjj1dhM6Hv3nFTEJp
         cvSpuxFnOuDFmrGlo6p6S6Rb6Tzo6lqiV5Y2E/z0EszmzTdnze6hWfKfcyflI2iAu5Xu
         Wx6T2vegWeMoiVPcw6CI5Y3rVlCKk9hjpOhAblMA6oCu6ZU4WmEUjotlY67g8Q+okBL7
         mDYphGS0ZR3l17HS8/Gbq1TuJRz/fWCiCO4zTlFVhg+MCDxPXhBDNcnR/BQA8ajfCX8K
         QZoKHT+Mrtscwlc+GNkX7mBtZinK9j4iue6pRfL7s3yk9tbUPlYWSG4bGtfnST1X9F8A
         kWCQ==
X-Gm-Message-State: APjAAAUqn3FWN6d5BwdG+ZcTeX5j9qCgrvyX6YhwamuVH3FB1Y8KgZFt
	PIPcZe1kUo4rI0iD6BajnxTW+tvhW9v+fgMjTxGxYMWJUNzmg6OdxVmZUnPf5nVl+w65ORHuQzH
	RNxW6CT5/ZD8qeZh4KHC+cyV/dzbfxeul3+4xKq7TMjG6CRglCN9iv1258ayQwSjQqQ==
X-Received: by 2002:a25:b31b:: with SMTP id l27mr35060251ybj.67.1552431441417;
        Tue, 12 Mar 2019 15:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVG4kpFg3jKH0AffVdXU3zqt2BdxoAKAnzVeb5/lq6papTAsvWtG31L12uVqVpT8Tw5s+8
X-Received: by 2002:a25:b31b:: with SMTP id l27mr35060215ybj.67.1552431440495;
        Tue, 12 Mar 2019 15:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552431440; cv=none;
        d=google.com; s=arc-20160816;
        b=PnkEVCdeF4aGir8AiaPgddXh+AcOLVp8kuihhVX2G9GGgq/PuQ4Pjf+MIf2bc9/XxN
         aywI2VObdByTE9qdMgyLfipTqEq9Sop3pBx7MW61iQo/hNgV7vQUyxUk8cdYYaOg2X7I
         +N1jlbBieQIbqZ8I9NL1nRjZ7xQOMB45vn+3o3OVx83IuKW3jTd5Uw3lvGfLQjkf+XoK
         sJyg6t0VEYkm8Ks8Wl7PwxjJpQz3Ylog/wWGZaw4sF5MQ1EqsXOd90MSptNq27iPMR5j
         32GabDgr5UpumLXXg2wclLcJEVcJP+8lMYDm87DkWWnpDUjKHai19eRRLUH+Iq3QImyv
         5IgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=5vFP26CUQPLhQhavIv7KLQW+HvC8lzvQsktord7sqXU=;
        b=QSLSeW8tzB6/1Y1/KvZaK5K8NchHk/GgG9QLsolD25obJBFYLx/VsE8QHcOXl4dA5p
         4/s0GQvxpouQvqLce4nn4c/ASO6Ma6PxmT0MolG7AX7gnGLU2VxuE3x/SyOOr2tac3zh
         t9eMqNWTftuxcew8Ljxo2FyMNTlCJ+FdjzCOeTd5w5KygWbko57Tliep6ObpX/Cnr8E5
         QoO4d6b/K6GyDfhJu6X/P00eMnO3GDTHHZcir5kzVncqC/yMAW+P5iyX2X+G7KB3X3NV
         oHWjtbNSQ5dcH5AIQDpEgpwh102OXoSGfELRFKk9W45sqGtxZyuiN0PsefTTY5S01Lmk
         Lm0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=TOJYB90P;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id s10si5487737ybg.203.2019.03.12.15.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:57:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=TOJYB90P;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id BB7C38EE20E;
	Tue, 12 Mar 2019 15:57:17 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bIXGJAv6LSQ8; Tue, 12 Mar 2019 15:57:17 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id D55418EE0F5;
	Tue, 12 Mar 2019 15:57:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552431437;
	bh=nqauZTMjLIlCtdjWAuZ6B+xT+zykoUqdVHDcgv40x8U=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=TOJYB90P8bGGBEgy/p2OzDozxFdWmdmTmVmEbZ2kxfHjm8Wnvw7af8NCL1GtxlDfT
	 CejvYaJVYV9EA/FkWkrN20QgY7XgolCcEnHjrMbejdgOOXNh3wKjFfiVxVq932K3Dx
	 h2zVGng+Z8FhH1B/f+R4JyloBXH9kXZ0FY4mGKB4=
Message-ID: <1552431434.14432.47.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
  David Miller <davem@davemloft.net>, hch@infradead.org,
 kvm@vger.kernel.org,  virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org,  linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org,  linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
Date: Tue, 12 Mar 2019 15:57:14 -0700
In-Reply-To: <20190312225032.GD25147@redhat.com>
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
	 <20190312225032.GD25147@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-12 at 18:50 -0400, Andrea Arcangeli wrote:
> On Tue, Mar 12, 2019 at 03:02:54PM -0700, James Bottomley wrote:
> > I'm sure there must be workarounds elsewhere in the other arch code
> > otherwise things like this, which appear all over drivers/,
> > wouldn't
> > work:
> > 
> > drivers/scsi/isci/request.c:1430
> > 
> > 	kaddr = kmap_atomic(page);
> > 	memcpy(kaddr + sg->offset, src_addr, copy_len);
> > 	kunmap_atomic(kaddr);
> > 
> 
> Are you sure "page" is an userland page with an alias address?
> 
> 	sg->page_link = (unsigned long)virt_to_page(addr);

Yes, it's an element of a scatter gather list, which may be either a
kernel page or a user page, but is usually the latter.

> page_link seems to point to kernel memory.
> 
> I found an apparent solution like parisc on arm 32bit:
> 
> void __kunmap_atomic(void *kvaddr)
> {
> 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
> 	int idx, type;
> 
> 	if (kvaddr >= (void *)FIXADDR_START) {
> 		type = kmap_atomic_idx();
> 		idx = FIX_KMAP_BEGIN + type + KM_TYPE_NR *
> smp_processor_id();
> 
> 		if (cache_is_vivt())
> 			__cpuc_flush_dcache_area((void *)vaddr,
> PAGE_SIZE);
> 
> However on arm 64bit kunmap_atomic is not implemented at all and
> other 32bit implementations don't do it, for example sparc seems to
> do the cache flush too if the kernel is built with
> CONFIG_DEBUG_HIGHMEM (which makes the flushing conditional to the
> debug option).
> 
> The kunmap_atomic where fixmap is used, is flushing the tlb lazily so
> even on 32bit you can't even be sure if there was a tlb flush for
> each single page you unmapped, so it's hard to see how the above can
> work safe, is "page" would have been an userland page mapped with
> aliased CPU cache.
> 
> > the sequence dirties the kernel virtual address but doesn't flush
> > before doing kunmap.  There are hundreds of other examples which is
> > why I think adding flush_kernel_dcache_page() is an already lost
> > cause.
> 
> In lots of cases kmap is needed to just modify kernel memory not to
> modify userland memory (where get/put_user is more commonly used
> instead..), there's no cache aliasing in such case.

That's why I picked drivers/  The use case in there is mostly kmap to
put a special value into a scatter gather list entry.

> > Actually copy_user_page() is unused in the main kernel.  The big
> > problem is copy_user_highpage() but that's mostly highly optimised
> > by the VIPT architectures (in other words you can fiddle with kmap
> > without impacting it).
> 
> copy_user_page is not unused, it's called precisely by
> copy_user_highpage, which is why the cache flushes are done inside
> copy_user_page.
> 
> static inline void copy_user_highpage(struct page *to, struct page
> *from,
> 	unsigned long vaddr, struct vm_area_struct *vma)
> {
> 	char *vfrom, *vto;
> 
> 	vfrom = kmap_atomic(from);
> 	vto = kmap_atomic(to);
> 	copy_user_page(vto, vfrom, vaddr, to);
> 	kunmap_atomic(vto);
> 	kunmap_atomic(vfrom);
> }

That's the asm/generic implementation.  Most VIPT architectures
override it.

James

