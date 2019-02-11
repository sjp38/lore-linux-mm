Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC61C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1836A21B69
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:30:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1836A21B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B788E8E0129; Mon, 11 Feb 2019 13:30:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28208E0126; Mon, 11 Feb 2019 13:30:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17318E0129; Mon, 11 Feb 2019 13:30:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC378E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:30:13 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id m3so10454792pfj.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:30:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TzCwq6tui24inIp47692ugtJAeN4QgQAFadC59B8j5Q=;
        b=t3CjqGl1hCAbTht1Kdt05qFRiXyHaCfZSPSnVhX/d5fErSLME/OWBZludid1f5/3KK
         zJfR1oWEc0w8Ah3S/qfb5VQTjhUbxUgqgIeO9HNRjTqhjBjjjBI21oZY74DV8xBJ3893
         cXW3zDz1T8JaDJrUdcBUOnXuaPvuUhdlcqVt4PVmY7A1GQngPXgnR67Cy3hv3PCRVdmg
         R09+hwXqaAql+bu4T0xkYsDifCwvNIF4BG72c7BjK3lod16CDxyVAcV4s7clacchnCCN
         SnKvtxkAnvajk7ixHBjczfUiu/3zZJMaXMC5u1G87jA66KAqC8ziO8DaOfsxP+F1wg5R
         9x6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYIbXX3aYirWYwnvI6qzBil3lKo/+LAMMR10H9o4zwxgzsw4J8Q
	MJ+uJl4lGxAxICGcT+qVw35T7h+FXPD/UxQHDmjLs0tgw/ZbDQrPI0sc3fhNCWgraKNZMki4yR6
	KflTJREUpRvuE/WJHf2YbCdRIcrAM2UrVy48pl4LSulNAeLHVyAdfuBrZBi+PB1iaaw==
X-Received: by 2002:a17:902:e087:: with SMTP id cb7mr33816139plb.313.1549909813077;
        Mon, 11 Feb 2019 10:30:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbURFZyEMY+kErcODgDxNkY1osxnUp9W84JXeOqJBf/HEnsJRGtoc0afwoy6857lYMBPDFq
X-Received: by 2002:a17:902:e087:: with SMTP id cb7mr33816068plb.313.1549909812275;
        Mon, 11 Feb 2019 10:30:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909812; cv=none;
        d=google.com; s=arc-20160816;
        b=EUyAJcHTe1HIb8/7fhg12lNb3OJtVWaciaAL17LrlQTjhbzjeF0H+9DSlGQULWs1dd
         RnUyyptxATddXOI9Vqkvumg2O5vijXk8Bf3L4c1dH1BIYhQZEB49wJy+7NgymteO/9Wr
         8yFTdQbsaq2gBVvDKgb4TBHRsZnx77UDFGy7+JuedSj+xGozVF/fm+Lad1LERvYzjK3c
         UUG1R+Q0hj7qp35Dr/Yj/5LtbXGfSjyA/o0ekd8I2z//dtavs8qcwrA3pOd2+z3YpzwM
         KABIS97IZwJrxw6Uo1fCF5wG5J9twRSpPP7m7oR2bk6siWTde0T+5x7WUjr9hXaY6do9
         qZ/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=TzCwq6tui24inIp47692ugtJAeN4QgQAFadC59B8j5Q=;
        b=ylZoiguojXERqEJF2tNxzX0MlbqUwqPLne2Tj1EwGNRvgawbzaq+ArjOpqYG45jGZo
         YCX0eiTzvJJ/cAUkDUHlEceCjjPUsoONZxeyBqMH3EdxlnVAX/8eZV4Xe4UK17R0rc5j
         mecIKL0LRHxJnW2SpIAt/UFdf2F3rpMPMcDfX1nwQRdB4K09tmhBpDK5veu1twrHNmkm
         2cdXKLUHFM+PIU3Qkn/uPKJNsbbw42nVLOCTI6BYc8VWdEO1sMWMLxKJ1yG36CSVaB0L
         3LCmZznRJRnh/paeCKlPcAq7AwHfHGUir3NJrB03pq2Z+sO16or+TeCsmvLq5xgdbiez
         DaXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y16si828359pll.105.2019.02.11.10.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:30:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 10:30:10 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="137749085"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 11 Feb 2019 10:30:10 -0800
Message-ID: <58e57acd628f2d6535fc45a028af50855158fda6.camel@linux.intel.com>
Subject: Re: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen
 <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, 
 x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 pbonzini@redhat.com,  tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 10:30:10 -0800
In-Reply-To: <20190211124203-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181546.12095.81356.stgit@localhost.localdomain>
	 <20190209194108-mutt-send-email-mst@kernel.org>
	 <39c915a7-e317-db01-0286-579230f37da2@intel.com>
	 <20190211124203-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-11 at 12:48 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 09:41:19AM -0800, Dave Hansen wrote:
> > On 2/9/19 4:44 PM, Michael S. Tsirkin wrote:
> > > So the policy should not leak into host/guest interface.
> > > Instead it is better to just keep the pages pinned and
> > > ignore the hint for now.
> > 
> > It does seems a bit silly to have guests forever hinting about freed
> > memory when the host never has a hope of doing anything about it.
> > 
> > Is that part fixable?
> 
> 
> Yes just not with existing IOMMU APIs.
> 
> It's in the paragraph just above that you cut out:
> 	Yes right now assignment is not smart enough but generally
> 	you can protect the unused page in the IOMMU and that's it,
> 	it's safe.
> 
> So e.g.
> 	extern int iommu_remap(struct iommu_domain *domain, unsigned long iova,
> 				     phys_addr_t paddr, size_t size, int prot);
> 
> 
> I can elaborate if you like but generally we would need an API that
> allows you to atomically update a mapping for a specific page without
> perturbing the mapping for other pages.
> 

I still don't see how this would solve anything unless you have the
guest somehow hinting on what pages it is providing to the devices. 
You would have to have the host invalidating the pages when the hint is
provided, and have a new hint tied to arch_alloc_page that would
rebuild the IOMMU mapping when a page is allocated.

I'm pretty certain that the added cost of that would make the hinting
pretty pointless as my experience has been that the IOMMU is too much
of a bottleneck to have multiple CPUs trying to create and invalidate
mappings simultaneously.

