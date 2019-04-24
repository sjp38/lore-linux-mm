Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 681C8C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21CE32183E
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:33:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Xg6OGbjc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21CE32183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6CE76B0005; Wed, 24 Apr 2019 16:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5D46B0006; Wed, 24 Apr 2019 16:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BF086B0007; Wed, 24 Apr 2019 16:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B68D6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:33:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q17so10531625eda.13
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:33:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ei50cL/3SAzu+3HwY4Rcgwlyq29ejpdQ2HpVb/S/D9s=;
        b=bKkrbcmMF04HQV5rd1EeS9fFix1wJwG/wF0QX5gGBgyNtFXSRUaaub9xyiX2LlyU7l
         oVIBqcV8ZDdqwoRXRpGVIFCn5J2ZyPBUr5YVRh95cfUICxEXiQqZ9zJyOZjJn05KcuJH
         opAa4yChpKdgadGEsuWbgZyQug6YhCp9Lp99wQdJig/k51wOqIZ0xZ9oaRXD2ME095O4
         SpsAT261ti/F977dVhbaYOsvx0PJSA+DgqnCNjaVycKF8M0btDydxTrnOImYgLwTOXkF
         YFdChkoUzcUkurR5VJsPi/l+cd6504FFDaWQ0h3BPeKtELGVxo/Yiwo5ncjSi87yYSGE
         swjg==
X-Gm-Message-State: APjAAAXxNMgdvFeEX5y77yAa1NJfwmGi8kXbIyEonYAG7iG1tdzBjVpz
	oAcKRKFUb61EEYkuZMAevqdv3LsO9rgpedfYXiHKPcJweIfkbEvL4qGVv51izrv+IfSF9XTZ7tY
	x93pHHpSJUDice610jWIv2oPJsfmul6yoLKfmVf/OKO/nMzKNgrC5zR6dYCZVq4ImfA==
X-Received: by 2002:a50:aa44:: with SMTP id p4mr21726169edc.214.1556138002772;
        Wed, 24 Apr 2019 13:33:22 -0700 (PDT)
X-Received: by 2002:a50:aa44:: with SMTP id p4mr21726143edc.214.1556138002092;
        Wed, 24 Apr 2019 13:33:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556138002; cv=none;
        d=google.com; s=arc-20160816;
        b=eEmaRZm9vfo54KZPUyAiiME+viZrbOhij97hPMM3uQaeUgQAGY05R32Ipi+zOVrmfC
         pPk/sBDYPIwGS7bjKdp+ANH8XnRa+Rr3B0v5o3NOVy4Fxsv1GYjl33DDsjbcdFAcT+DF
         KiViZek6HCqUZtCnzwrueHTOKd3YNPNmgtt7VEw496Iy7CmxJAKRQhHhYe9v3nnM0jdf
         DkK6hI3Q3BaAZs+c+oxZfsAxaiiwNv6W5CbGxRC+8OFKWeOFRQmiLmhGw4mPhc2UAmjJ
         YOBPw+hOOFJfECFcl6MicSeCZEmSzAyQGN98Qprk084vX0uLaQ73uM00wXRguvlwNo1Z
         qezw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ei50cL/3SAzu+3HwY4Rcgwlyq29ejpdQ2HpVb/S/D9s=;
        b=iSGxAGvzErGoe/jVTqd7tyH+ZDK3BrrTlMGOg2lQeoAOAQFnZtjttxcJELNSfvv9Jn
         C0P5ZbFClq5dYSQVl6YWYLiTT6oZm5l6NMZuxjE2s6fr4yLKTWv12M490XTsXYmtRyIZ
         ZtSGzpIINZN7CPsiGDPw/kRWhHkmWIXKJq5YpNHV3k9aEavpFjehP4gOzcvKRyzVV55W
         ThlGpaBsTV1d7WFWMSK52Pb0Irb438N3kdrmoREqt1/EolAlglAOzyITE060dUXXDMkH
         HZVh516b0jomL5QjraTw3L9F1A/geJVZEfGHkUHPNIczjHNZDbj7oJOu5X158juborFB
         YShQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Xg6OGbjc;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a36sor10987753edd.23.2019.04.24.13.33.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 13:33:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Xg6OGbjc;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ei50cL/3SAzu+3HwY4Rcgwlyq29ejpdQ2HpVb/S/D9s=;
        b=Xg6OGbjcfyaLCpDFhcTnpTO0iMfD/817X5nad/yjtudZp5QywW5weHOdb9geKQ7fX1
         ajO0Auw6e7a4gakil7TmM47F5054UAHeVoyNPrkYi+mNkbiGhzoVnTy1MynMu+Wt68Tf
         ULl93eCOPa3lJ4pns7KmMESX420Hf7IZC7uVPgB2WAsPleGBaRmWciy10fbmrvie4EK6
         Jr3BmDrWGQQcIYj8C6hYyk/5B6ISkKIdFBT1Mca66lY2iEViy9Rctii5QifP2/JpbyIw
         DUdETDpUjrFDaCsYEPKNAo08kyX6zXVxe1ANGYqmSy4C8EsKxZ9RQtakVGdSkEPfqqkL
         +Puw==
X-Google-Smtp-Source: APXvYqxagCAaBl5kqo4ujsFeZlClVv7V6IZGrmsI+2EHtCmYLQuoHtSZQewi6mFo2fEG0MV854NdLjtX1+fNETp2fVs=
X-Received: by 2002:a50:89cd:: with SMTP id h13mr20624076edh.79.1556138001745;
 Wed, 24 Apr 2019 13:33:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com> <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
 <CA+CK2bB5ahqLrekkTUSdzTE2BPSPbB9nk6nKs+LjTap2oF8X-w@mail.gmail.com> <CAPcyv4gdo5GcS8cbvLQr0Ez09z32VyrbVouW2GVV5UJf8R3HWw@mail.gmail.com>
In-Reply-To: <CAPcyv4gdo5GcS8cbvLQr0Ez09z32VyrbVouW2GVV5UJf8R3HWw@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 24 Apr 2019 16:33:10 -0400
Message-ID: <CA+CK2bC7iEsg8Fdep6kphNTNroCi_zi1ejApspSZyTq_VFvxOw@mail.gmail.com>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Dan Williams <dan.j.williams@intel.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, rppt@linux.vnet.ibm.com, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com, james.morse@arm.com, 
	Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> This is yet another example of where we need to break down the section
> alignment requirement for arch_add_memory().
>
> https://lore.kernel.org/lkml/155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com/

Hi Dan,

Yes, that is exactly what I am trying to solve with this patch. I will
test if your series works with ARM64, and if does not I will let you
know what is broken. But, I think, this patch is not needed if your
patches are accepted into mainline.

Thank you,
Pasha

