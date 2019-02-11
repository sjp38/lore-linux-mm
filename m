Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92FB9C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:31:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5923B222A2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:31:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5923B222A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 039388E00FC; Mon, 11 Feb 2019 11:31:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00BE8E00F6; Mon, 11 Feb 2019 11:31:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA18A8E00FC; Mon, 11 Feb 2019 11:31:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2128E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:31:36 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so10144905pfk.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:31:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4cy7grFDYUyFfHY/W3+2vAqDBT61YVM1UOU4OP3+q1Q=;
        b=k/l9Z0W+hyoYZa3lCy/1aMcZTQ3JSPODLeftie4cfM9X5rPz1KQ6G5gPPddb3kARoU
         OI0s+TRS2ttD+GDX7G9ADuOBpCAJJHA2x7fnglx6CqmjQMr3fr9eFQ6hW8siHPHVcTsY
         x+45E8uJnqCT76wzX1E/EPUdWMfCRbYSY3eeLcsXWkI/9Up+GgNUG6k4rW+Wu9HIIJXu
         /t4QJuQ1S4+3Ve+XaCYLzZLU+vc9nK5Glx8/isC0/SGV9AUTCzbksEke836J1FJpvfht
         iBEEqnStObNcYl81eJt1fLbxMGimNaCt+Pq0kLP6Gtp7b4L5xIQyNlhyUH+Fw3XfPOiI
         3B9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZb8fam1W50hzMq8kOpV7FGYMLh02GYhmDHvX2vWEtiFsdlNQqk
	eKVCniCzyrtRF/UH0sYsDIcdKpEpaPj4o1va8r3D2UmOAqZHghi2XvUtc0VknsB6eVKuMlvMCg8
	B9/W9taoQ8zt+H/oZk0XQW3IFL0Fl7gC3yN7ckZVJsRctFkMgeijBN6PbyCsxPiVyHA==
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr38828498plb.332.1549902696183;
        Mon, 11 Feb 2019 08:31:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYehhnc3gu9pM6joV4moNmy8okUSZCrGBIDTuWxO1L7nMS7F9uzsNTwux0NPwZr/nIts9YZ
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr38828430plb.332.1549902695371;
        Mon, 11 Feb 2019 08:31:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549902695; cv=none;
        d=google.com; s=arc-20160816;
        b=ChMHwBZ4Ijt1+ZOQlsgV80/E6S5rVQQuoNkRaN5Pkb4Rng8l6PIJ4e/rCd+spBQP1N
         y7FFXeGLXK3FmewHyeY+lV+tNwIuZkeHtO8aNWoW1+ZyfigUrU7a26sJc7DHvRXPxDQm
         CRm7HvTdYNkrB0fRn4spEsnCO8eTkutbsOxkzzwUsFkfUfYib3Wl2EG2F554dnaJdP4L
         puAvOQJt7w8EhLrQdI0MZ3i51GrG2kbaImmfe+VAAwgcK88BNEXIxGCpOwbCGyxKF64N
         RwzW4C/4Z159iotBGN99vas5i2Y8stlbUPiuvx0HTKDehAOR98YSk4VEXwvcibrhisEP
         +XhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=4cy7grFDYUyFfHY/W3+2vAqDBT61YVM1UOU4OP3+q1Q=;
        b=TMxbBSftmcmGCxdBWF9c0iRziuemhLjnOQME8ieEkytQnupS2+sO7eKfjCh9/o1QIP
         Vyjr7J65xCCuR82wA5/71nOFQ4PmgA35t/RTSXhHHgMmahJk5i6W2pRC/ov6aO1HTYDo
         OYo2kvtr4QXm3mkov6sqXIdlGex+ZHhHbYXXN8SQUbUTC+Ohygahl8e5pNFARN65y2Qa
         58ckGOBf2WKsovJDSF0J47bjR0xmHSXhuTyGRvZJjT/nA9AbinYfFVcSAKrGfsYMb6iw
         QB61zsmtMr+y5Oj+TuedOuW2tWlQJAZLlgvPCLLMejYNVK/nbl74dsOXlRnJvi2t6Nrq
         x4gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p12si10213752plk.77.2019.02.11.08.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:31:35 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 08:31:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="117019570"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008.jf.intel.com with ESMTP; 11 Feb 2019 08:31:34 -0800
Message-ID: <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, 
 rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com,  pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 08:31:34 -0800
In-Reply-To: <20190209194437-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <20190209194437-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add guest support for providing free memory hints to the KVM hypervisor for
> > freed pages huge TLB size or larger. I am restricting the size to
> > huge TLB order and larger because the hypercalls are too expensive to be
> > performing one per 4K page.
> 
> Even 2M pages start to get expensive with a TB guest.

Agreed.

> Really it seems we want a virtio ring so we can pass a batch of these.
> E.g. 256 entries, 2M each - that's more like it.

The only issue I see with doing that is that we then have to defer the
freeing. Doing that is going to introduce issues in the guest as we are
going to have pages going unused for some period of time while we wait
for the hint to complete, and we cannot just pull said pages back. I'm
not really a fan of the asynchronous nature of Nitesh's patches for
this reason.

> > Using the huge TLB order became the obvious
> > choice for the order to use as it allows us to avoid fragmentation of higher
> > order memory on the host.
> > 
> > I have limited the functionality so that it doesn't work when page
> > poisoning is enabled. I did this because a write to the page after doing an
> > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > cycles to do so.
> 
> Again that's leaking host implementation detail into guest interface.
> 
> We are giving guest page hints to host that makes sense,
> weird interactions with other features due to host
> implementation details should be handled by host.

I don't view this as a host implementation detail, this is guest
feature making use of all pages for debugging. If we are placing poison
values in the page then I wouldn't consider them an unused page, it is
being actively used to store the poison value. If we can achieve this
and free the page back to the host then even better, but until the
features can coexist we should not use the page hinting while page
poisoning is enabled.

This is one of the reasons why I was opposed to just disabling page
poisoning when this feature was enabled in Nitesh's patches. If the
guest has page poisoning enabled it is doing something with the page.
It shouldn't be prevented from doing that because the host wants to
have the option to free the pages.

