Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E022C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 18:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35B20218A0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 18:53:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YP1CWkmH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35B20218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5086B0003; Thu,  4 Jul 2019 14:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B661B8E0003; Thu,  4 Jul 2019 14:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A847F8E0001; Thu,  4 Jul 2019 14:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F79F6B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 14:53:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t2so4124841pgs.21
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 11:53:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=hMjGnCmxgTsdf+ch+FUZeL4hcJLJYm2lehB4zlDk10Q=;
        b=UPxsUca/Mx/io07eMiR0Z50QFD718RMuYyyFbrQ1QCUTbsOAGm5DBjFwqpJrqfbFFO
         q8tLgOqTCTdnkLebuuLvBL5NRpsgx7NvwemXqW37wm/lYU/eJ4rPm3jnW0C73oGMmi1A
         HmZH3qcVVlfvN+RS6Ana12TJ5Sw+NLFFwrsM62GKbKL0p1lH4ykQNrWNwTve2y/h/j8W
         FE0hGWWZ44HRPY7fh+XqRRZlRsdlpCBMsW/+60uIBi1oMMNy056fHK5cnpNItIWf0oS7
         VwyySNCOTrcuYiIuO8+00iy77V36k/EiY2Pd0K8Iy8fk7iAH33JsLGddCzp++ZlXiddt
         YbbA==
X-Gm-Message-State: APjAAAXPLJOmaFDUrnNLMlqf/6k2Gn8EWDnqZyccO3Z4BFBYqXcBXQj1
	PJYt7JjA3U+W2iRXhPOW4sXshoXRp2HX2J57nUwqh8wkAiqAa05rYodWL1NHx+rKLDTshcexYGI
	Xiawf7uDlTPu0NkoWdwkZZs/DOn6LdXDzcr88cgHlMYOR1ax4+9IILYkG4AK/h5wgTA==
X-Received: by 2002:a63:79ca:: with SMTP id u193mr11685883pgc.91.1562266406803;
        Thu, 04 Jul 2019 11:53:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7oX1AfjQAfqWDWXDkdKE71EtidTn20/N7rpQYj+Fisq0ntpk5WPGx7KRmlgipkz9AOQ0y
X-Received: by 2002:a63:79ca:: with SMTP id u193mr11685838pgc.91.1562266405865;
        Thu, 04 Jul 2019 11:53:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562266405; cv=none;
        d=google.com; s=arc-20160816;
        b=XbhOuSvQ5LUGlB2r2FjvfKEos/lw5YJz2rKcp1QLtNziPPPEVgtvG/7ytKZ+DKfl2/
         irYHfQALJXn/bC0pMnu9rfl9Zmm4xJTE7dqPPyKVavqk4mlLzT9byVL8RcrTrg7mPxFw
         FcrBCjYA20R2c7eE4Zf1b8kUji+avILOiDwICBnC2Xn8xmn+s5pYUnlubiPdpb4xJhe4
         TicumFSNwnanjW0I4NwOFgJeB05tvvP/nxafT4Pn93UoiyXsP0TPcjnupbzQGWjtqevt
         h/o4c8UCY8QkihhcK6uNTEyU2Y0W+LLr+aG4V4H6lCPRR6D1iV/xkFKnX9P6K8BkEptI
         cM+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:to:from:date:dkim-signature;
        bh=hMjGnCmxgTsdf+ch+FUZeL4hcJLJYm2lehB4zlDk10Q=;
        b=F68mAS9ZFwXnbU2BFZDy0cZsPyotX9UVYh4gBHU4VWtb0wxHFIaNcfJiKK0pIytU6Y
         gj1ziYyYTQMxLjRb/MQo5ifGJdht+OA/MeFYAWQ3b5wPpR1rwllU7XdB9Tx7qj6DzIur
         S/IJaOYU6xL1kXu/sf3lZR8m5vLL3zLXxl9ucJkCPwugc/UWewchzrRxRmMoFtKsASVx
         Py/5M13HJd+CPhwKXpOZHobPmqrwYz2qXFbUIrsesYCh9ea3v8/kIShGZAeIQf4wM9hk
         1P6gChqgsUEVXxUoH0AtmaRJsRGv3o64Xd0ITOF2r7N/G8Xt4OfgeBJBigAb51lr9BGU
         YTEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YP1CWkmH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f19si6052579pfd.137.2019.07.04.11.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 11:53:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YP1CWkmH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AFC8621738;
	Thu,  4 Jul 2019 18:53:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562266405;
	bh=qkDBOADvWshMyVN7H3BLz2q7D8CF8WI3UnSO0p9XJrk=;
	h=Date:From:To:Subject:In-Reply-To:References:From;
	b=YP1CWkmH0JmPvIb/iq31MuI00kd3EDa/9+C6FkMW9xNGhHlkejojh07VR/3oy9+KK
	 IaMaAVuXl15/ma/jlj84cLS06pu+hF+aZFECnsfjJYLa1fqDGmLqdbwVk7A2KeDeKQ
	 /qpQ+nlJ635aiqGfp36Mf66+8oo8W3i8EH5ciKR8=
Date: Thu, 4 Jul 2019 11:53:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig
 <hch@infradead.org>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
 <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com"
 <catalin.marinas@arm.com>, "anshuman.khandual@arm.com"
 <anshuman.khandual@arm.com>, "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Robin
 Murphy <robin.murphy@arm.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-Id: <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
In-Reply-To: <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
References: <cover.1558547956.git.robin.murphy@arm.com>
	<20190626073533.GA24199@infradead.org>
	<20190626123139.GB20635@lakrids.cambridge.arm.com>
	<20190626153829.GA22138@infradead.org>
	<20190626154532.GA3088@mellanox.com>
	<20190626203551.4612e12be27be3458801703b@linux-foundation.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 20:35:51 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > Let me know and I can help orchestate this.
> 
> Well.  Whatever works.  In this situation I'd stage the patches after
> linux-next and would merge them up after the prereq patches have been
> merged into mainline.  Easy.

All right, what the hell just happened?  A bunch of new material has
just been introduced into linux-next.  I've partially unpicked the
resulting mess, haven't dared trying to compile it yet.  To get this
far I'll need to drop two patch series and one individual patch:


mm-clean-up-is_device__page-definitions.patch
mm-introduce-arch_has_pte_devmap.patch
arm64-mm-implement-pte_devmap-support.patch
arm64-mm-implement-pte_devmap-support-fix.patch

mm-sparsemem-introduce-struct-mem_section_usage.patch
mm-sparsemem-introduce-a-section_is_early-flag.patch
mm-sparsemem-add-helpers-track-active-portions-of-a-section-at-boot.patch
mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal.patch
mm-sparsemem-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
mm-hotplug-kill-is_dev_zone-usage-in-__remove_pages.patch
mm-kill-is_dev_zone-helper.patch
mm-sparsemem-prepare-for-sub-section-ranges.patch
mm-sparsemem-support-sub-section-hotplug.patch
mm-document-zone_device-memory-model-implications.patch
mm-document-zone_device-memory-model-implications-fix.patch
mm-devm_memremap_pages-enable-sub-section-remap.patch
libnvdimm-pfn-fix-fsdax-mode-namespace-info-block-zero-fields.patch
libnvdimm-pfn-stop-padding-pmem-namespaces-to-section-alignment.patch

mm-sparsemem-cleanup-section-number-data-types.patch
mm-sparsemem-cleanup-section-number-data-types-fix.patch


I thought you were just going to move material out of -mm and into
hmm.git.  Didn't begin to suspect that new and quite disruptive
material would be introduced late in -rc7!!

