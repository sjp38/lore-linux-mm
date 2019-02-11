Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FBC2C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36B8521B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:58:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36B8521B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB5C58E011B; Mon, 11 Feb 2019 12:58:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D164E8E0115; Mon, 11 Feb 2019 12:58:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB8188E011B; Mon, 11 Feb 2019 12:58:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8664F8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:58:18 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id v4so13520033qtp.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:58:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=2s0fwScnnU0B2HePDKiiQeuMAXgskFElOd16Txu1Wc8=;
        b=DJnthst2TRDOuFGyWPocYRdIzZmA0gNObsEsHrVMEGvsQqCp+XLI7giaLmrMTVQbQR
         9kti54q3edbi+UqjLC5Ln22KkuMqJhHLAJlVOn50isHi1EAAfe/Lfrk4CG2wgvfICfkK
         V27bJgWgQNTJvVwZMjv6nZOYQqn8E9x2/Rx/kDAv3IdofPh1w4x6EJuuK5xYxPUVQnwN
         ScqKiW9MK/rU+76beIE92SQn+/POKjF91xtNOcnuPyXICg3rUwst3+LIbHyMpxB3rS1z
         BMFeMst0VJA8zup85rEFbS8Lpair2kL4TDgSLiToToLrWiuflNFIgYkuw+4c8nOzbqnH
         D/Eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubNSa+PQ8hiLcRpF1e0kH1CGxQx6S9II8A2TRl239+SwKVRQRZl
	ZLzGMrWz2Tj1fCBucT46sXA2FeQh2CshC8P0LaNDRsSlA4zMSE/Hd0QyuIBPGV8L4yBkRScWnB7
	Z/l5r3JnLuPDHCo3m058NrH7Tuq8ZeY6jSGiS+sQXC08QsDt4HdsqxdU6BiqKaDGlHg==
X-Received: by 2002:aed:3722:: with SMTP id i31mr28898996qtb.289.1549907898323;
        Mon, 11 Feb 2019 09:58:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVMxfex6jEqmZzlGqUpzd0vIiab8icTOgDXDBsOG+vvtgueak/6rQS8U7BKfJUzPHvcbPx
X-Received: by 2002:aed:3722:: with SMTP id i31mr28898977qtb.289.1549907897875;
        Mon, 11 Feb 2019 09:58:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549907897; cv=none;
        d=google.com; s=arc-20160816;
        b=k4RrfMjRJ0fJsH3vaQLg0E1Bo35G0E8NaITMjuLEvMRJDApTz4mBCLajvmW96M1uia
         2vrWipDwaSeMGdFxJYDcrgjzgCv8yeXRWYwfnvC27vZe5PZ9R7ADlsqFPdCX1LZJguLI
         iOF6TADCYGy9K7/Co4+hE0eMTFDY74Sog0QhLkzQr7ARuTUpBBG3WPWNhpmsIwQrGKTa
         Eeg27D4plTqfgvRfez8LSNf0V3+4wkw0+eECd3eLKffu5mPsXj6VTd/nTtLgfiGM4xBF
         pEMlIkESduWKXLegM4I76Vzuw03VaWwHiYh+PWjLfpcVeZwwXHQfLs6PgxvmOBzXY930
         40cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=2s0fwScnnU0B2HePDKiiQeuMAXgskFElOd16Txu1Wc8=;
        b=fgoalnxklANZYsesLvAIC939nOIJK9EmTdi/qdaWxJzrQvHnZbHA3QSwB7wgxD+Z17
         iSZoJfNR1j8UIpsSgo0xtr1lxUUK3sUJYFoW4lb1e9qZsU3eQbRhdlCYvN4b4kh3iiXr
         FORb2ExViGsWwpIIGWf616eRDl9GVcv/nPKqJj1ufz02HUxVOL6pm8TIxFMw1Lz+vmDA
         F/HilZYYx8jvfr693TljF89oWNMfLenwHoqc4jMdaZFDIDIr7POLu4iKfnv4Kfg53mOx
         FTj4TC9RpbSeUS+TZ9Fhh0IgU0ikU/rOA3FahplV17RkMQNzsTI1MBunenGEd/PP6ELt
         //Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c20si1084519qtp.401.2019.02.11.09.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:58:17 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 01238369A0;
	Mon, 11 Feb 2019 17:58:17 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id 64A9E5C21A;
	Mon, 11 Feb 2019 17:58:15 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:58:14 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
Message-ID: <20190211124925-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190209194437-mutt-send-email-mst@kernel.org>
 <0d12ccec-d05f-80b8-9498-710d521c81d2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d12ccec-d05f-80b8-9498-710d521c81d2@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Feb 2019 17:58:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:48:11AM -0800, Dave Hansen wrote:
> On 2/9/19 4:49 PM, Michael S. Tsirkin wrote:
> > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> >> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>
> >> Add guest support for providing free memory hints to the KVM hypervisor for
> >> freed pages huge TLB size or larger. I am restricting the size to
> >> huge TLB order and larger because the hypercalls are too expensive to be
> >> performing one per 4K page.
> > Even 2M pages start to get expensive with a TB guest.
> 
> Yeah, but we don't allocate and free TB's of memory at a high frequency.
> 
> > Really it seems we want a virtio ring so we can pass a batch of these.
> > E.g. 256 entries, 2M each - that's more like it.
> 
> That only makes sense for a system that's doing high-frequency,
> discontiguous frees of 2M pages.  Right now, a 2M free/realloc cycle
> (THP or hugetlb) is *not* super-high frequency just because of the
> latency for zeroing the page.

Heh but with a ton of free memory, and a thread zeroing some of
it out in the background, will this still be the case?
It could be that we'll be able to find clean pages
at all times.


> A virtio ring seems like an overblown solution to a non-existent problem.

It would be nice to see some traces to help us decide one way or the other.

-- 
MST

