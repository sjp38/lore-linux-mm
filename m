Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C5CAC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01486214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:22:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IuNT+1bU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01486214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60FC46B0007; Tue, 20 Aug 2019 02:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BF4A6B0008; Tue, 20 Aug 2019 02:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 487986B000A; Tue, 20 Aug 2019 02:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 225676B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:22:24 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B494A52B7
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:22:23 +0000 (UTC)
X-FDA: 75841811766.25.trip09_14d5852a4b802
X-HE-Tag: trip09_14d5852a4b802
X-Filterd-Recvd-Size: 7977
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:22:23 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id c81so2724908pfc.11
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:22:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LsEyAPx89vt71C2UmHMLuXRw1EoaUy3zZsSSBMjTLq4=;
        b=IuNT+1bUdIOlhn7H8uUFCTAobEvaJBujn3erlMwDQC4XnfPp941Brrlh4bOm1JIb6C
         YQbCY4ZrSrv0PBkJqivNVgfv5FSUMyTCduQzs6Qv0iBt10S4ljTiS36YU4zSsp2I83Qa
         OYfWzh3nwz6xFWE7zBeeYmcioTJA0LhMSr1QAa5RkZ1xoZDOv4+VO8M7OWDQ6q1x9Xu6
         hFmFOsWsGwP7DidMrLTUjR5Tq7Cq3egd3vGVKflW8ipMFBVe24yWNkjOGhfX+wj8aMN6
         kJ7wvRSxdSvDoOYU1vX2fWS6bDlJ/mA1rgJXkfgcLcvkkmon8T1cNVY5Xxefi09QLIZ5
         xtrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=LsEyAPx89vt71C2UmHMLuXRw1EoaUy3zZsSSBMjTLq4=;
        b=c+6Bu1Ah03C2JPjN2oTL98H9s3ZcArYyQ7A+f+HGhHOS5L/GmLZz3mL6LvINe+ZUok
         8Mmr7bD7xF+aOQD6SqmQRqTbpHxBthukgH2hakn0elG0cuxNAs98TbSG7ANuNB5QcNnI
         wIr1IsT9s3VPkWZRGrSdhCua//MytPPVkEtW+e739KnV2zxDzzGo2j2z5gommZly+x21
         f0ViP2gziSLKDkj4Tt1+iGpTLW4duvkudUYwkZmI7GojCcAKo7BLNlOvbnz+oAw2Wau/
         Ek/401dKgnbYvobKflYF5N1fIcGPvaABul72jAPuFToRf+gH/mW3i6QT9mWwEoJZaoH5
         IN6Q==
X-Gm-Message-State: APjAAAXZ57IbHZb8+K9dfJt0N0jjR3utNNp14fv1nxiZE6sSR90iPkuz
	F0eHTP0XHcuOYvblVfWmxZ0=
X-Google-Smtp-Source: APXvYqzExR/3Tv53UARjp6aMbWOaY9pNVjpL0tL+F1uW6x15j6WkwwSDnJHx07vWyy0iTH4pbvRfFA==
X-Received: by 2002:a63:fc09:: with SMTP id j9mr22343328pgi.377.1566282141988;
        Mon, 19 Aug 2019 23:22:21 -0700 (PDT)
Received: from surajjs2.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id 2sm24482074pjh.13.2019.08.19.23.22.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Aug 2019 23:22:21 -0700 (PDT)
Message-ID: <1566282135.2166.6.camel@gmail.com>
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
From: Suraj Jitindar Singh <sjitindarsingh@gmail.com>
To: Bharata B Rao <bharata@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, 
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com, 
	sukadev@linux.vnet.ibm.com, cclaudio@linux.ibm.com, hch@lst.de
Date: Tue, 20 Aug 2019 16:22:15 +1000
In-Reply-To: <20190809084108.30343-2-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
	 <20190809084108.30343-2-bharata@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-09 at 14:11 +0530, Bharata B Rao wrote:
> KVMPPC driver to manage page transitions of secure guest
> via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> 
> H_SVM_PAGE_IN: Move the content of a normal page to secure page
> H_SVM_PAGE_OUT: Move the content of a secure page to normal page
> 
> Private ZONE_DEVICE memory equal to the amount of secure memory
> available in the platform for running secure guests is created
> via a char device. Whenever a page belonging to the guest becomes
> secure, a page from this private device memory is used to
> represent and track that secure page on the HV side. The movement
> of pages between normal and secure memory is done via
> migrate_vma_pages() using UV_PAGE_IN and UV_PAGE_OUT ucalls.

Hi Bharata,

please see my patch where I define the bits which define the type of
the rmap entry:
https://patchwork.ozlabs.org/patch/1149791/

Please add an entry for the devm pfn type like:
#define KVMPPC_RMAP_PFN_DEVM 0x0200000000000000 /* secure guest devm
pfn */

And the following in the appropriate header file

static inline bool kvmppc_rmap_is_pfn_demv(unsigned long *rmapp)
{
	return !!((*rmapp & KVMPPC_RMAP_TYPE_MASK) ==
KVMPPC_RMAP_PFN_DEVM));
}

Also see comment below.

Thanks,
Suraj

> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/hvcall.h          |   4 +
>  arch/powerpc/include/asm/kvm_book3s_devm.h |  29 ++
>  arch/powerpc/include/asm/kvm_host.h        |  12 +
>  arch/powerpc/include/asm/ultravisor-api.h  |   2 +
>  arch/powerpc/include/asm/ultravisor.h      |  14 +
>  arch/powerpc/kvm/Makefile                  |   3 +
>  arch/powerpc/kvm/book3s_hv.c               |  19 +
>  arch/powerpc/kvm/book3s_hv_devm.c          | 492
> +++++++++++++++++++++
>  8 files changed, 575 insertions(+)
>  create mode 100644 arch/powerpc/include/asm/kvm_book3s_devm.h
>  create mode 100644 arch/powerpc/kvm/book3s_hv_devm.c
> 
[snip]
> +
> +struct kvmppc_devm_page_pvt {
> +	unsigned long *rmap;
> +	unsigned int lpid;
> +	unsigned long gpa;
> +};
> +
> +struct kvmppc_devm_copy_args {
> +	unsigned long *rmap;
> +	unsigned int lpid;
> +	unsigned long gpa;
> +	unsigned long page_shift;
> +};
> +
> +/*
> + * Bits 60:56 in the rmap entry will be used to identify the
> + * different uses/functions of rmap. This definition with move
> + * to a proper header when all other functions are defined.
> + */
> +#define KVMPPC_PFN_DEVM		(0x2ULL << 56)
> +
> +static inline bool kvmppc_is_devm_pfn(unsigned long pfn)
> +{
> +	return !!(pfn & KVMPPC_PFN_DEVM);
> +}
> +
> +/*
> + * Get a free device PFN from the pool
> + *
> + * Called when a normal page is moved to secure memory (UV_PAGE_IN).
> Device
> + * PFN will be used to keep track of the secure page on HV side.
> + *
> + * @rmap here is the slot in the rmap array that corresponds to
> @gpa.
> + * Thus a non-zero rmap entry indicates that the corresonding guest
> + * page has become secure, and is not mapped on the HV side.
> + *
> + * NOTE: In this and subsequent functions, we pass around and access
> + * individual elements of kvm_memory_slot->arch.rmap[] without any
> + * protection. Should we use lock_rmap() here?
> + */
> +static struct page *kvmppc_devm_get_page(unsigned long *rmap,
> +					unsigned long gpa, unsigned
> int lpid)
> +{
> +	struct page *dpage = NULL;
> +	unsigned long bit, devm_pfn;
> +	unsigned long nr_pfns = kvmppc_devm.pfn_last -
> +				kvmppc_devm.pfn_first;
> +	unsigned long flags;
> +	struct kvmppc_devm_page_pvt *pvt;
> +
> +	if (kvmppc_is_devm_pfn(*rmap))
> +		return NULL;
> +
> +	spin_lock_irqsave(&kvmppc_devm_lock, flags);
> +	bit = find_first_zero_bit(kvmppc_devm.pfn_bitmap, nr_pfns);
> +	if (bit >= nr_pfns)
> +		goto out;
> +
> +	bitmap_set(kvmppc_devm.pfn_bitmap, bit, 1);
> +	devm_pfn = bit + kvmppc_devm.pfn_first;
> +	dpage = pfn_to_page(devm_pfn);
> +
> +	if (!trylock_page(dpage))
> +		goto out_clear;
> +
> +	*rmap = devm_pfn | KVMPPC_PFN_DEVM;
> +	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
> +	if (!pvt)
> +		goto out_unlock;
> +	pvt->rmap = rmap;

Am I missing something, why does the rmap need to be stored in pvt?
Given the gpa is already stored and this is enough to get back to the
rmap entry, right?

> +	pvt->gpa = gpa;
> +	pvt->lpid = lpid;
> +	dpage->zone_device_data = pvt;
> +	spin_unlock_irqrestore(&kvmppc_devm_lock, flags);
> +
> +	get_page(dpage);
> +	return dpage;
> +
> +out_unlock:
> +	unlock_page(dpage);
> +out_clear:
> +	bitmap_clear(kvmppc_devm.pfn_bitmap,
> +		     devm_pfn - kvmppc_devm.pfn_first, 1);
> +out:
> +	spin_unlock_irqrestore(&kvmppc_devm_lock, flags);
> +	return NULL;
> +}
> +
> 
[snip]

