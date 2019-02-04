Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E7BC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A3E2080A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:51:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A3E2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C5F08E005B; Mon,  4 Feb 2019 14:51:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 976488E001C; Mon,  4 Feb 2019 14:51:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88BDB8E005B; Mon,  4 Feb 2019 14:51:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 450778E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 14:51:13 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p9so685989pfj.3
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 11:51:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cYWukXHUOKdtgAanB/xzUQ0UMQUFtMMe8Xl6LN1N7FQ=;
        b=PFIxGR45KMvzHGbH2namu+BFW7bfHNPuQSsujaD0pu/T/cw0KrND//uUkSmzKJEkX/
         vA1q8DiQ06o3nkqpdH55kwKucS3aXjp77PE+LNk2b8IPKTlOyS3CGQ7b+FfqzYm2Fc1y
         lpWy8U5pjUzIs9PyNf50AF6eY3kfWrwD3RQzfWoY1a7MBD/jkdSmnnUVdnAoOKBC9GJH
         aXiALiDDjvjF13G4TgDZC/b5r1OYAlSakWXLfL+Xl6O5nONa25NtVvMBJXpc1z5UTogX
         apCR9z+O11n9u+LRdQ82dAxiy5G+l2LYdWRhcku+D37gezHY9OoSTa6RgKkaCWuDJHyt
         iTOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZm8/yd+fMuKa5fK1Ka7MLRskYtwe+uHxDlYZsCtheWq+Lb8ZWM
	cHxtB0Ia8Z+IH34zl0fZIHB/4Ml1cPO9Ie3SOxI9meaG/hwV0HYmEPa8sSM8mUxLsP9EX3Igbm1
	kpmfZbN97JU82FpMPz/COosk4xEIggnRHjuDg3j47/XwMJn0BZcph+XwU2HW3o91oRQ==
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr1130539plr.128.1549309872912;
        Mon, 04 Feb 2019 11:51:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib2Zc4WzQxNQ7jqCD9PUe9GQIAO5PBPzIaHGT7L/xdN/z3pVEUHMdUbDzpX7nYT8/G7aRUC
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr1130475plr.128.1549309871995;
        Mon, 04 Feb 2019 11:51:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549309871; cv=none;
        d=google.com; s=arc-20160816;
        b=K+6VmL1+pHQpV1lYNIYCpZmWAwJsQngmfkMVCcyzBRgjHbg1gztX6ELVbPEUvki0g2
         I1cjQ9Wu8F35gxaj0YF9dn5mPQ/dFHfE4qG8Gp7Dz68ZBc/jDnKIpRdXkPBUVxVGiXHG
         XIBJJ8O3gRlhIz/F8p8fJlBGFrfqGpDury1AP8nBtB42/sshd3R0VE3wNFHJg3lU36HX
         BeAIR0g5YtyNaTLnfaeF3G+HaWE+gumVY81BBt+zQgo+71BvFItq37Nm7Wc5WC4LCwsN
         OEGbDDRRQ8zrsvyFiLAiVv8OeAjebgMCIiy6u2bexJ5vEMwFbJvgDNhddCzZBw/CkE6d
         z5PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=cYWukXHUOKdtgAanB/xzUQ0UMQUFtMMe8Xl6LN1N7FQ=;
        b=TQX26Tpm1SxqVIlToNNATsRm5D7oTMzWpTwaCQHKXEKXfryu5ZvZFF0iJMIz5F6qz0
         MqSMK37/S51KNdETqNM2Oi6GiceMlJh9iPCWpkZwC/KauCQhPpqNgeNywR181EB6zFOu
         zkrnJbfJEaRXrjE28u2bHveNAmo6i0wk3G2N6W4Ex1fpl2eXNr2WOrZEteBrfZ3hRF+D
         VJlI+uL3sm7fOIqAZA9uXa0t0WKIsHejQoIJsDWEwMvnls813ALKOKdyfNTQ+hEn/83L
         FFmPwf5w6Ro7E8+BBoo3ojvUOaPxrmdzVZQK9V3fUxPyK8zUJ0f5XSmAstxGtxdZx2PL
         FwJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i68si940156plb.325.2019.02.04.11.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 11:51:11 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 11:51:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="297217646"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga005.jf.intel.com with ESMTP; 04 Feb 2019 11:51:11 -0800
Message-ID: <10fe638278abc129eff53779cffb476f4fcbbf64.camel@linux.intel.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 11:51:11 -0800
In-Reply-To: <33d14370-b47d-5ceb-09c4-41f0d6b33af8@intel.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181558.12095.83484.stgit@localhost.localdomain>
	 <33d14370-b47d-5ceb-09c4-41f0d6b33af8@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-04 at 11:40 -0800, Dave Hansen wrote:
> > +void __arch_merge_page(struct zone *zone, struct page *page,
> > +		       unsigned int order)
> > +{
> > +	/*
> > +	 * The merging logic has merged a set of buddies up to the
> > +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> > +	 * advantage of this moment to notify the hypervisor of the free
> > +	 * memory.
> > +	 */
> > +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> > +		return;
> > +
> > +	/*
> > +	 * Drop zone lock while processing the hypercall. This
> > +	 * should be safe as the page has not yet been added
> > +	 * to the buddy list as of yet and all the pages that
> > +	 * were merged have had their buddy/guard flags cleared
> > +	 * and their order reset to 0.
> > +	 */
> > +	spin_unlock(&zone->lock);
> > +
> > +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> > +		       PAGE_SIZE << order);
> > +
> > +	/* reacquire lock and resume freeing memory */
> > +	spin_lock(&zone->lock);
> > +}
> 
> Why do the lock-dropping on merge but not free?  What's the difference?

The lock has not yet been acquired in the free path. The arch_free_page
call is made from free_pages_prepare, whereas the arch_merge_page call
is made from within __free_one_page which has the requirement that the
zone lock be taken before calling the function.

> This makes me really nervous.  You at *least* want to document this at
> the arch_merge_page() call-site, and perhaps even the __free_one_page()
> call-sites because they're near where the zone lock is taken.

Okay, that makes sense. I would probably look at adding the
documentation to the arch_merge_page call-site.

> The place you are calling arch_merge_page() looks OK to me, today.  But,
> it can't get moved around without careful consideration.  That also
> needs to be documented to warn off folks who might move code around.

Agreed.

> The interaction between the free and merge hooks is also really
> implementation-specific.  If an architecture is getting order-0
> arch_free_page() notifications, it's probably worth at least documenting
> that they'll *also* get arch_merge_page() notifications.

If an architecture is getting order-0 notifications then the merge
notifications would be pointless since all the pages would be already
hinted.

I can add documentation that explains that in the case where we are
only hinting on non-zero order pages then arch_merge_page should
provide hints for when a page is merged above that threshold.

> The reason x86 doesn't double-hypercall on those is not broached in the
> descriptions.  That seems to be problematic.

I will add more documentation to address that.



