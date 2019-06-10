Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B996BC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 761D720859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:26:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="X3Tymq+l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 761D720859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15DFC6B026C; Mon, 10 Jun 2019 13:26:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E216B026D; Mon, 10 Jun 2019 13:26:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F41436B026E; Mon, 10 Jun 2019 13:26:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2DE76B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:26:19 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id i138so3106081vke.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:26:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qSkPLH9vDolbJlk5XvbY4CtX+5a/+fS/moYDl/wZCzc=;
        b=ZX7en/YIGfQn6Pj3j3dbBdqGyzt1q+69+SjdRkVJDZz7wpxFFpg9Vr+uCf3ROQvmLX
         du3mAyUqWK4zplINM4Xx7FUiJBpt4Jx9RkNVZUrHEUFom5tf0mNOW13cAO2QkJVQRdTC
         gWVrd38u4xHhSIPqZiwc8mDrOkMzTN0muut5l6ojL8gmkkT60lH7mwPXhJyl9mAGWTDo
         vIHNZpd56gP6kP9Vhldx0CL9EkGdxtxOj8rykqHWUm8yN0Uf8wX4GO0xMX8gdZDicQbG
         i+fV8T4ng1ZIMc7p62FgC6yenrUR1KjqRTJc9HNUqR18DF8FrqCTR89TWxaEKtVOfKK0
         Yn1g==
X-Gm-Message-State: APjAAAUqOXOcf/TmY0bwLbWLsK0Kg0D+9kfsPybt8WfNj4cr+szLA4BR
	dv+wTZOAhwTKKcJ9lYKMhlT06WtVJ/B0ynZuOW0pqXBFkdbQuSSridvfNRIPX4p/9n+nBwVOPfc
	o/KoojV1/wwsPf+1KDlMH6I4X/urlO6v9s/6eyNlXNIrpdXJdrEu+M9Cao707KoJvaw==
X-Received: by 2002:ab0:7252:: with SMTP id d18mr7036283uap.23.1560187579559;
        Mon, 10 Jun 2019 10:26:19 -0700 (PDT)
X-Received: by 2002:ab0:7252:: with SMTP id d18mr7036205uap.23.1560187578879;
        Mon, 10 Jun 2019 10:26:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560187578; cv=none;
        d=google.com; s=arc-20160816;
        b=p3fawBz3iP1Nd3J2tLjaTGjJcXPYKKIhpSrtwARsq9Jqc8+ZbIpF/mI3sdoAXPfTHW
         x6N1fPxQ/f9t5EJDxGxPTup2657A6bEjr0eulFmtTXQkSioKwNbdifVpiEKMmHkjyyG+
         CkzdmMtrvxni2qYZnsei+iedkFUaf1FmVfVZjnhH28YZgTi0kzfOgezNz0kMDQDO9MOQ
         inQ8tmZYn76RSiLBM57N//Mk+cTsm00tf9u+6c1VcAoF0i00RW+baVG8xxI5yXFsx2yl
         BLykYJ3R5QnoLREqCSh8BuAkvEOGBfDtz/NNGjmq9Hjl5HVhaQilyBtt3Oj5X0nLH2uu
         oXQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=qSkPLH9vDolbJlk5XvbY4CtX+5a/+fS/moYDl/wZCzc=;
        b=gjvlA6/NriDOy+6RFaVJY12lII5maLcFyHdXo+k4jhJUPSXSqQDLnP5H6fFbwvtY7a
         LsM+RRmMt5QzmpIunY65keiI97sZMAoMPAi/crXwS+sZe4CdGM1s/DQGPoE7SULmh4QT
         EMqhXJ4gijE6QrpE+0ARQV2IJksSwjhxtRh6bri8ItdL6PP3KOI1fmwKBLArA11t/DFc
         0Up1NZFKMuStZV2PcoxDjBtcnHnp4Z4FnzoWueMTBDYjDlqeiQU8q6+U8HV6xrX9YwGd
         EmcQqgZNjlJvVVL6ovrXxNbrdB1RYDZny4qRaEoQ4a7M2/6uVQniIBMI65sIoYgrLo2f
         55yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=X3Tymq+l;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a25sor4661473vsn.97.2019.06.10.10.26.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 10:26:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=X3Tymq+l;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qSkPLH9vDolbJlk5XvbY4CtX+5a/+fS/moYDl/wZCzc=;
        b=X3Tymq+lxR/tOVHDBtZz1webVwVCP2s2oH0yXtVQRx3F32sM/CMH9jfTJyOBuymJKm
         AbMh0J4rg6ag0Vr4a6szOR3XFKbXYEsuf2pDjpqlniCE88NG1+QgtA+I4bUYf20y6G5j
         qbmJ5YPzUYXwPkWRulV6e89Bz7Yi1Tac77kreGT6csAXiPEOiieFiFQIazrLMFSy6nkR
         os18qdAJHoUPec7y2vIYdi37NRolbTVYeS8VJKE9CK5NgF0+axbk/jMZYOoulIbJ90sY
         M840savZid7ZE8+ALK7/oDvvu4+jmXF3g66cBYskWNvrubs9qRXg+eJjoCiWfwQz2O5u
         SlJw==
X-Google-Smtp-Source: APXvYqzCcBGzDjZnnnKYmBeaeDQFD2Zt4lSSiUrvfHl8DQYI4Et3/NEeN/1OKaheEtva1osez+Nw7w==
X-Received: by 2002:a67:8712:: with SMTP id j18mr28306727vsd.4.1560187578484;
        Mon, 10 Jun 2019 10:26:18 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id d78sm4039758vke.41.2019.06.10.10.26.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:26:17 -0700 (PDT)
Message-ID: <1560187575.6132.70.camel@lca.pw>
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
From: Qian Cai <cai@lca.pw>
To: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: rppt@linux.ibm.com, akpm@linux-foundation.org, catalin.marinas@arm.com, 
	linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, 
	vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org
Date: Mon, 10 Jun 2019 13:26:15 -0400
In-Reply-To: <20190610114326.GF15979@fuggles.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
	 <20190604142338.GC24467@lakrids.cambridge.arm.com>
	 <20190610114326.GF15979@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 12:43 +0100, Will Deacon wrote:
> On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> > On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > > The commit "arm64: switch to generic version of pte allocation"
> > > introduced endless failures during boot like,
> > > 
> > > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > > -2 parent: cgroup)
> > > 
> > > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > > and then later memcg finds out those don't belong to any cgroup.
> > 
> > Mike, I understood from [1] that this wasn't expected to be a problem,
> > as the accounting should bypass kernel threads.
> > 
> > Was that assumption wrong, or is something different happening here?
> > 
> > > 
> > > backtrace:
> > >   kobject_add_internal
> > >   kobject_init_and_add
> > >   sysfs_slab_add+0x1a8
> > >   __kmem_cache_create
> > >   create_cache
> > >   memcg_create_kmem_cache
> > >   memcg_kmem_cache_create_func
> > >   process_one_work
> > >   worker_thread
> > >   kthread
> > > 
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > ---
> > >  arch/arm64/mm/pgd.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > > index 769516cb6677..53c48f5c8765 100644
> > > --- a/arch/arm64/mm/pgd.c
> > > +++ b/arch/arm64/mm/pgd.c
> > > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> > >  	if (PGD_SIZE == PAGE_SIZE)
> > >  		return (pgd_t *)__get_free_page(gfp);
> > >  	else
> > > -		return kmem_cache_alloc(pgd_cache, gfp);
> > > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> > 
> > This is used to allocate PGDs for both user and kernel pagetables (e.g.
> > for the efi runtime services), so while this may fix the regression, I'm
> > not sure it's the right fix.
> > 
> > Do we need a separate pgd_alloc_kernel()?
> 
> So can I take the above for -rc5, or is somebody else working on a different
> fix to implement pgd_alloc_kernel()?

The offensive commit "arm64: switch to generic version of pte allocation" is not
yet in the mainline, but only in the Andrew's tree and linux-next, and I doubt
Andrew will push this out any time sooner given it is broken.

