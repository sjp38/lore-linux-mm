Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29318C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3FF32183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:07:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="DpzX2uJT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3FF32183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FA1B8E0023; Wed, 20 Feb 2019 11:07:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18DF78E0002; Wed, 20 Feb 2019 11:07:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04A748E0023; Wed, 20 Feb 2019 11:07:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1C48E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 11:07:14 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f4so10959071wrg.9
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:07:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FuWrqm3gYIKjPp/OIyk2H5wvXxskQnamgQncl/lDD4g=;
        b=eIYGpCvdVsFWekhURiObil0gDqX1UvpOQeP9zbaK9R9BdHtBzCFeD7LlVusGMHlJro
         dgO+bLKZ7DGC3STJRyqza0kDx8ti88WJWFrV8pbKA979ASf/IHrN9UZ6WRcSRxY5yHCe
         A0YE5keeod6foG3VqupA7LBwz6JKHduzURjCawF7Hisrk4RTaUHa0dwoSe8G6bWJWgBo
         S8qQArMlhUD7dHAnIN7/rCIQU4Z3QRWWpb5hn8AXQ7/eJ82oYZFhQCI5ovSsBwjhZzE7
         e4cmmz9+JI8yla+eGSnlI1S8SXdAignCPeQvWp6xjAZb7LOV8gcjR9iLk75PZYsNb5dN
         MiYQ==
X-Gm-Message-State: AHQUAuZQfYU0ckb/IuysqTvzjFKFv+wI6Q5SluBZxq+i2chZqVTQHuO+
	GiTrWGuLVESfVKdYgDKFYTPybUh/poM9N9VwOTZMssm9zbtg7ufkSQI4pe5HpkRoL8EuW7trUbt
	dyHmIaR0MaJH5C2eAavkBQpwkrb2UwN50tXcyBpChxbzPnfGg1t2kwoqv4JAZLtGoTg==
X-Received: by 2002:a1c:a74a:: with SMTP id q71mr7446886wme.45.1550678834201;
        Wed, 20 Feb 2019 08:07:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1u6BfY7yzYvaxy/3GPyG2cCjnCw/8KtQ8RT4MljMR7VCtOks4CdsxcwJxp0ZVOqjH8EYA
X-Received: by 2002:a1c:a74a:: with SMTP id q71mr7446812wme.45.1550678832946;
        Wed, 20 Feb 2019 08:07:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550678832; cv=none;
        d=google.com; s=arc-20160816;
        b=CCDotYxSgBH7Dbqx/1s23LYxOsReQpuGaZjKUMrrI4PJphlWs6NFd66NCSwDfyw16f
         G6IBZQu6rsh8zO+/GoghDLvE/SSQM0+BaEcDmJ1qpmHXDb2Fe5nxR49YB1nkRRHM+XLX
         jNOiR7eWKiB3QdET3m07/4ZoqaKQnEi3Q6byffEsc03gtmKlnwFWLZ5QEk5eqMdF49gl
         Ullap1C/XPZ5x1qwOLvS6Hru3WoRBJYY1BqvPpvom3l6c8Ji4RVxm/CUV3AlbwQSV8P1
         /p/icfIvqTfNf6oe9yG8Lqss24YLS2gxeDQ5w43qpwVO5EmsqpnBvkwgCGn5qKJptoNq
         fFMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FuWrqm3gYIKjPp/OIyk2H5wvXxskQnamgQncl/lDD4g=;
        b=0jcopOXnaNbBujPNiQFSsNjLINJQh1D4/0q1m71jxs6gSbovz3FRnEPObaQYiNqnxC
         KCA4wlN0r4VQ7pQ7kbsg3BIf1Z5QR886Htf60z4cNTy5V7eSVNbuyW85+kBBT8cXHhaf
         q87r37PBhUbAgfXb3kXzFkOomlVak4VuebFXzlS1sT2Q3Kc2k2YpYpvpbDIRfa+pvetE
         2aJLSFhRNbbKsMEVgD6wS5KNepFlCaH9nbUMuCel2m8WUgMKBKcR4lHpLPCOGhpjw+ff
         apU9pG6K3JYgjqofgwaXFNMKj5P+3wj3/Bt1dwq304WFU5mTevxHh4zr850EDJEZ9Xn8
         vLZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=DpzX2uJT;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id 71si14034069wrl.91.2019.02.20.08.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 08:07:12 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=DpzX2uJT;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB85008CB41DEE22243FB8.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:8500:8cb4:1dee:2224:3fb8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id C8BA21EC0375;
	Wed, 20 Feb 2019 17:07:11 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550678832;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=FuWrqm3gYIKjPp/OIyk2H5wvXxskQnamgQncl/lDD4g=;
	b=DpzX2uJTFznTEjpd31L8k3uyQMoAFpgLU8lA/Ya7UBoOQFWC3YY0qJMXIrWh/pC9+7Ao3v
	xNXOsGv4+u6RVMGexsvnSWvr0Gy7c4a+HqE/yjbSxMrnMBiumPNvRFdjGCMHIEn+E9kH2A
	F76Uq/Q0Uqj7Fuhk1zu9rh3uVNQkHlg=
Date: Wed, 20 Feb 2019 17:07:03 +0100
From: Borislav Petkov <bp@alien8.de>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>,
	"Dock, Deneen T" <deneen.t.dock@intel.com>,
	"pavel@ucw.cz" <pavel@ucw.cz>,
	"linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"linux_dti@icloud.com" <linux_dti@icloud.com>,
	"luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"rjw@rjwysocki.net" <rjw@rjwysocki.net>
Subject: Re: [PATCH v2 14/20] mm: Make hibernate handle unmapped pages
Message-ID: <20190220160703.GD3447@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-15-rick.p.edgecombe@intel.com>
 <20190219110400.GA19514@zn.tnic>
 <07ea2a4a9f1771f7bad82ad8fe5ee9483b79d115.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <07ea2a4a9f1771f7bad82ad8fe5ee9483b79d115.camel@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 09:28:55PM +0000, Edgecombe, Rick P wrote:
> These are from logs hibernate generates. The concern was that hibernate could be
> slightly slower because of the checking of whether the pages are mapped. The
> bandwidth number can be used to compare, 819.02->813.32 MB/s. Some randomness
> must have resulted in different amounts of memory used between tests. I can just
> remove the log lines and include the bandwidth numbers.

Nah, I'm just trying to get an idea of the slowdown it would cause. I'm
thinking these pages are, as you call them "special" so they should not
be a huge chunk of all the system's pages, even if it is a machine with
a lot of memory so I guess it ain't that bad. We should keep an eye on
it though... :-)

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

