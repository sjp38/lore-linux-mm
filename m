Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 892DBC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:34:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45DBE2229E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:34:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45DBE2229E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2AD8E010D; Mon, 11 Feb 2019 12:34:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E388F8E0108; Mon, 11 Feb 2019 12:34:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDA498E010D; Mon, 11 Feb 2019 12:34:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 882178E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:34:27 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so10307400pfq.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:34:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LPQ0NAtKDMPm6CxxOglL8HW9f3oqzQiHpreLseXG/0U=;
        b=nPWqbjY3FP6mBjvhxi41wtZT6tfUtJDKk6Hta9jHd26ThkhM0OACkXFGPAJ/cO2cHw
         /1iodHFSELDiRANJHh0U7Q2f/wjYhOVUoV2/1p30Di16GuJ1/a028Im8/1EO7TYxitsy
         4xPZMtH6/HyVMH8HpiJSLFOLO5p2T/FiubE4upPaFhSHzVV837nPFWW5Vkzn4jwSlFCG
         Q7mssS1p1qc4nN3PZ46Crlfgp5it+PvrTjCTnAy6+TA4wZxp7hNZ8plzTjQ6y3DGnO+l
         6l/tzDwcbN4b5pKdpeBFF7UPyH54THTR0aH9uj5o1PHo7M5QPGplb5S9MqsLfMR8PiBK
         MbWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYkr+1fFpTZxhvH35MUS7En8v2iB77uTL2/jt+VlqhjfolPJLa6
	sPneJg9NUZQOZ6QmDQOhhvsgRrU/6ASX3I015ZVswoW8fwIa2F+bpkTcVt7qHxmbsMAtqGNmkGz
	NyWyFCaHkc6K+pbsACIx38CkN5MBRjzzfF3exrTBcaOnMR92tG8xefFryeoKL/C/n2Q==
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr39422185plq.286.1549906467182;
        Mon, 11 Feb 2019 09:34:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZakm81A25kyJoQNka7/9LRRHB6LOxivb1e6TwXBjbMxE+f1lJEa/ZEipZC5JUEp9EQfg9R
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr39422146plq.286.1549906466488;
        Mon, 11 Feb 2019 09:34:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906466; cv=none;
        d=google.com; s=arc-20160816;
        b=bz/1wqc8zyUU6qKPkn+ufgGUlB1rqWns8cwxEM68LJWuV8GbBE2HMLcF8SMt6R+aJr
         6BNSWunKkifSWGPWyBOHN00Ic2FO8jykOThC6Q7Tb/7xKoSZJCrxlOzoEqSVZhO3lMvX
         GDIE7VLfPC0Ui1GowqNyzXACVWrqZ+LQ9o3uhxsakfMkTKhb2CtHTzr9fw3Nv6Dc1nwF
         f7a8DIdVC9EtVNbOk0ShLr0ITGLInCZrtuJfJi1au1CcJ8DnDb4fSipV4gAtREm6rzmI
         EpEf1eOhO9yRAsLSLpz6D0TVlQK8405MdX1Dnr9iOQcPKfqLfbMvo3z4Z/MNPmElZQ0g
         QiMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=LPQ0NAtKDMPm6CxxOglL8HW9f3oqzQiHpreLseXG/0U=;
        b=MT3oIfS4pBMi/61JKIaiTEDQrCd2MsaP2AN7MbA+NUbXs2BEDZdKL4jx/yGm5WLLLu
         rxUsQCvqgLhWe0FV9ttxkTLzxgQYJsu2t74Xpts3yeDoOZN/Wr54+EIF/ugK0B0eR2TU
         Btd2ay8s32uuG6kQZCJkK05rv+zVsL+8KmzdBPcw2TIbO3ga0cgTRSbPQ6bQH/q6MqBl
         BYTAtuCy6tI5wwzjBGSGCT2GIR/lkbIM8YXR+U42lYiBlJ4WwKyVlR5PFiBgg7PsHJiv
         7JL1mOS55sL6yDybSZKj1J+Mw/afYCjKvN9n8TO6woqwI8u1HaI2q2ikL9dnKDpM6Ot+
         p/5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k125si10423709pfc.21.2019.02.11.09.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:34:26 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 09:34:25 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="117035838"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008.jf.intel.com with ESMTP; 11 Feb 2019 09:34:25 -0800
Message-ID: <96285ed154dbb92686ca0068e21f5e0500bb1ce7.camel@linux.intel.com>
Subject: Re: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, 
 rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com,  pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 09:34:25 -0800
In-Reply-To: <20190209194108-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181546.12095.81356.stgit@localhost.localdomain>
	 <20190209194108-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-02-09 at 19:44 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 04, 2019 at 10:15:46AM -0800, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add the host side of the KVM memory hinting support. With this we expose a
> > feature bit indicating that the host will pass the messages along to the
> > new madvise function.
> > 
> > This functionality is mutually exclusive with device assignment. If a
> > device is assigned we will disable the functionality as it could lead to a
> > potential memory corruption if a device writes to a page after KVM has
> > flagged it as not being used.
> 
> I really dislike this kind of tie-in.
> 
> Yes right now assignment is not smart enough but generally
> you can protect the unused page in the IOMMU and that's it,
> it's safe.
> 
> So the policy should not leak into host/guest interface.
> Instead it is better to just keep the pages pinned and
> ignore the hint for now.

Okay, I can do that. It also gives me a means of benchmarking just the
hypercall cost versus the extra page faults and zeroing.

