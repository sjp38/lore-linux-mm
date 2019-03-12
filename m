Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A520AC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:19:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B5B7217D4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:19:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="oZJBW5KX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B5B7217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2DDD8E0005; Tue, 12 Mar 2019 17:19:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDB458E0002; Tue, 12 Mar 2019 17:19:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA3688E0005; Tue, 12 Mar 2019 17:19:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB6958E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:19:26 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y9so5125077ywc.22
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:19:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=sAcfbpiYOITQV7uWwt/dNV3TazH0jY9UBT5DYBSscAY=;
        b=k56kr6tj3gASF/flwrpqSi9hj+I+0sQYqBlgldtKEeCnunOURngTms7gTOj855BYYW
         JraMz3ByF2rEbaf3uAwAy/KThUbMEIPVw6hHXU0+GbGN+PKp294gFdO26bUaQtNFSOgq
         1llPYx8MsCVL2XJ97Dkrn120Z408i9y/EjlqCbePX1oYQ+6j6qL3Mv+WfLMbBdENsjr0
         r4iKC9Vtmpx6nNzwTyDIIUYzl/J8X7LQElfaL+ErUOA/pp1ZVDDc9E+nJqONCmvi+dmP
         2nCAfiM+HtpolG9xKs7wEZfR8caFEn3DJtspNF2qvTGava2RwAKclBQm0b9j1AF3n/cT
         sgng==
X-Gm-Message-State: APjAAAXAm4p+vY+KJ3aUSS1mndCtcidBSNz7iSRrgzkXii09xk06UGBa
	GBu5QX1GVbUzQmfF20/3Bb8I1hH8pf4GTId+wzxKsNlvWA6JxlktXUrBEF1HCG3yN3MIapUOzoE
	mTLqgiuQHJEsjt/ONhlbymWPx187C4UkBiqnG0UekKqSkfWw58DoF9A4cO5eK9P+BGg==
X-Received: by 2002:a81:6e0b:: with SMTP id j11mr32283551ywc.160.1552425566446;
        Tue, 12 Mar 2019 14:19:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO8XW0eeHjJ/43+jfT62zew0pwpbBuxkGSRXvHZo8dtkknN6KiRrw2ZKAa2yyACzujcE7V
X-Received: by 2002:a81:6e0b:: with SMTP id j11mr32283514ywc.160.1552425565690;
        Tue, 12 Mar 2019 14:19:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552425565; cv=none;
        d=google.com; s=arc-20160816;
        b=GQUoWnL1dHJfi++P4VaoWBTVIEoT87FkHNPi8x/vRrWLQOTSd3fYUfM4CQTVfTTmIB
         2gmYyGnvvDZyVJT1E60AGYXlzKuPqzd3P7F6P2WfJdsn1ukZAv/JhQySU2T/utlU6ZBr
         Ldc6R/iIyTaA1gb+Z9kOeFrvpYBZnR4Xv4lhgnSjPeUoZjAdAriZWm6D3yhuB5s1JJ04
         BlKoycZ1MKQqmuToKwCZBSE6kLdu41LYgeRbx8rQf91d0wLnGN5KnlFt/uidVxCi/CmH
         UQ3FfebjkBwr3cZ1TiX9MHkOxnQ20yQ09zecLx0uV8OSPC3F1cMvWxuJbTBvr/UCSTAi
         NjAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=sAcfbpiYOITQV7uWwt/dNV3TazH0jY9UBT5DYBSscAY=;
        b=oUQPu8eBNfBBzKhOzLFVmerk1qhNkkAXdGGQosJIDyFrQmANx9bb7/LO1bxJK3RLBR
         rYLvrW5p3iMFwCQVtkrqenQuR+YFlfqF8CDrHKRtNY6z7bMrZdqKg/iBhZcf5sb1Z3YI
         g92DqT+U562AkKPsLVBwJd/4UFzddtZTPQX/Zn5jkcC8ym/FviPMuck7+EwzEsGT9rdh
         jRrcxOVk9dmYpSr9YivxwQUoCjSYLYnthIx3C+s1JoP4w9GuUZrw9AnNXB5a4DkgFrwD
         wKSHRUe8/ffg3z6mxruqnb+i27er1AkxvucsEsJ9NBPA4bKgZYp6eOQonYq3dfAaRjdY
         YvYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=oZJBW5KX;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id k68si5269449ywa.135.2019.03.12.14.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 14:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=oZJBW5KX;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id EA5AE8EE1ED;
	Tue, 12 Mar 2019 14:19:21 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0xVaCC_S7-6v; Tue, 12 Mar 2019 14:19:19 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id C9EA58EE0F5;
	Tue, 12 Mar 2019 14:19:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552425557;
	bh=nBucg5nObt1KlK9vb8n4aq4g77BNSYrOWjbZNOJxaqk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=oZJBW5KXIW92FCi6QYBzLSNeWSzJczWdOOQlss5aFpWMkuj7ltNJ+LRAhD2lIbB4W
	 7ZJzTIkaZ87beykikhhLN79fTZ86C1lTnEXB1mXKruoOmDSwDzVZV64VafKNPy9HKW
	 m+NIZUEPLnH92JH1Y2UNiobJjLrtRC8VYA8p/+kg=
Message-ID: <1552425555.14432.14.camel@HansenPartnership.com>
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
Date: Tue, 12 Mar 2019 14:19:15 -0700
In-Reply-To: <20190312211117.GB25147@redhat.com>
References: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	 <20190311095405-mutt-send-email-mst@kernel.org>
	 <20190311.111413.1140896328197448401.davem@davemloft.net>
	 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
	 <20190311235140-mutt-send-email-mst@kernel.org>
	 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
	 <20190312075033-mutt-send-email-mst@kernel.org>
	 <1552405610.3083.17.camel@HansenPartnership.com>
	 <20190312200450.GA25147@redhat.com>
	 <1552424017.14432.11.camel@HansenPartnership.com>
	 <20190312211117.GB25147@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I think we might be talking past each other.  Let me try the double
flush first

On Tue, 2019-03-12 at 17:11 -0400, Andrea Arcangeli wrote:
> On Tue, Mar 12, 2019 at 01:53:37PM -0700, James Bottomley wrote:
> > > Which means after we fix vhost to add the flush_dcache_page after
> > > kunmap, Parisc will get a double hit (but it also means Parisc
> > > was
> > > the only one of those archs needed explicit cache flushes, where
> > > vhost worked correctly so far.. so it kinds of proofs your point
> > > of
> > > giving up being the safe choice).
> > 
> > What double hit?  If there's no cache to flush then cache flush is
> > a no-op.  It's also a highly piplineable no-op because the CPU has
> > the L1 cache within easy reach.  The only event when flush takes a
> > large amount time is if we actually have dirty data to write back
> > to main memory.
> 
> The double hit is in parisc copy_to_user_page:
> 
> #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
> do { \
> 	flush_cache_page(vma, vaddr, page_to_pfn(page)); \
> 	memcpy(dst, src, len); \
> 	flush_kernel_dcache_range_asm((unsigned long)dst, (unsigned
> long)dst + len); \
> } while (0)
> 
> That is executed just before kunmap:
> 
> static inline void kunmap(struct page *page)
> {
> 	flush_kernel_dcache_page_addr(page_address(page));
> }

I mean in the sequence

flush_dcache_page(page);
flush_dcache_page(page);

The first flush_dcache_page did all the work and the second it a
tightly pipelined no-op.  That's what I mean by there not really being
a double hit.

James

