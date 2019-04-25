Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94115C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:57:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10287206BF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:57:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="S8gasJAV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10287206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0570B6B0003; Thu, 25 Apr 2019 13:57:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006336B0005; Thu, 25 Apr 2019 13:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E11806B0006; Thu, 25 Apr 2019 13:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD396B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:57:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21so143022edx.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:57:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/lfFoLZ1bSmGmdUbBHFXNJ+M6oegr5l9R4TFlcxu7Mw=;
        b=keK69tov1z12At0tisP3etuxcmORpOSscGZeCHF4svghi6khkRGPwBXgLgAy0wkU0T
         zPRDTSfLX5Wg73+coNZwGyQF+eWFRIx3D8FCxdpuYDU958c6gb6lqTA7koaZsZAv5a+g
         GcZwDfmEUmJ9JbJRG1r2wuJfLYrhqiypR2pIox2ZtomH/BK/Yr3Zrlcql1210bhRqI7D
         RwOvqsuKXfS3jfNY4Wz6yAtZXOPDhi6FBTgN3ZaM1TFLrebwr+5bEpljjg9t9qhLc/RO
         C2/CTSQZI4lCKKpc7J3MIxgCWDCaoVUWB2OpQo5d9Pp/MUgWeLVEMkxDFo2/8pUwCKPX
         i7Xg==
X-Gm-Message-State: APjAAAXMr7TVRrr74Vrel44CsjMlz3x909ST3P1XSi4bINCkAg1YOfAE
	ODL/mtIKdFA5Rp3LL1a9d9Rf3M1RBB7dpgCs+wyMOMzDGxk/cW+kI9Y0ClqWW2TYcf++/j08DE2
	XNXvMYOCQIpwgTSGBJ41Bfpj0Ekp0HeQBMxrjDWIANJx2PKGSSD8on8f+h0e+99aL+w==
X-Received: by 2002:a17:906:25ce:: with SMTP id n14mr20498532ejb.115.1556215058018;
        Thu, 25 Apr 2019 10:57:38 -0700 (PDT)
X-Received: by 2002:a17:906:25ce:: with SMTP id n14mr20498499ejb.115.1556215057179;
        Thu, 25 Apr 2019 10:57:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556215057; cv=none;
        d=google.com; s=arc-20160816;
        b=cKb9dujUn6k0erJ7SaJagDLmLOuGiou2iIxSRNJpvVhV+SmrLzFhKJHs/4Ie88AJ0V
         AswhVFeTh9DW726btzoCar+PU39kSFWI3cSufpY1bUrDy9FdkjFvqf4q7btFDnrdZQT5
         aflkY86ULy4LEiGfGtnlyq2xMeRXfzeVKknwJWt3NxTW0j+gYhxUkduLUv9QrU9mu/y9
         BUCh9ycYjj7YTMpwxRVafdLO/3eUOMOeJQFXcy8nllq7vzCl7u37jnn4qX9IqAX9jgDZ
         vwcanY/4wdqcCdQRi9IjL5kXhq1WA7J8vSE76jvI8Fvf4jS28VxYXv4DfwZqrUlQUgUg
         +6rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/lfFoLZ1bSmGmdUbBHFXNJ+M6oegr5l9R4TFlcxu7Mw=;
        b=B7nBF6Xgc8timlxw/DHUdAtMnL2yFiw17g84Fb6GxpwUe0Ni/QPXaX1ijxf6IxVut8
         /rI12vCIm2tUn2SCKFbNLsoTTt9n69XOE2eVqJDKj6wFrlZAnTtYuJQBVKLPPEskiNaN
         fncT4EEWwsH286LKchJ2YbOUJrXtz+LIyxsjdzEKr3egkhGboIaLPyJ7pn8+evXC8aNa
         0JsPU3AZR2iHoPkkxWFHDAP/xWYdPsJ8uT1U53Xot66t57tbmdegLNXfMJETK4uowcDI
         YYPJtj0d9veDuWdAi743h0KSzNzkdv7DoQDpcnOqKG6dnPfDwhxIKLFS0+6gb7Q6zk+0
         pmRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=S8gasJAV;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m19sor5165224ejd.6.2019.04.25.10.57.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 10:57:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=S8gasJAV;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/lfFoLZ1bSmGmdUbBHFXNJ+M6oegr5l9R4TFlcxu7Mw=;
        b=S8gasJAVn+ZWmiT/2uWvL9vkKwOoktSsgWDJ2pt28Jwb8U3hd4RYZILlgs1ZJSbb32
         E8pkwIX2WZ5U7s0jN5OFpHJANArcLfSTG2WfhU0d/yE03quAyfTD+ozv8EsylrGARl0T
         Q47fyZiS5Uwz5G+0wsjfnj+2u2oPWY05lYUanIDY7LgNL4FubQm9/F7oW4oEqNThrg84
         gLONpjU+mkfLCeD5a8uQeIbLsAUPMjwvrtbFH/bnTAbaqEuYWZAP012PG9WJeaoH5kLo
         K72nQU2oKXRez7H4b59QLM2pnJhyW8VIp8FGqSBLbgfBlnZF9Iex1qPjic/qyWHcnHbT
         3/XQ==
X-Google-Smtp-Source: APXvYqw1cnJsUKvmbES+9b09tCQYh+M//QuIDsABsPOCGjahHfAnSjITfrASIQUqNSCPM/SZxSQ7kryctJSAM+dJY2g=
X-Received: by 2002:a17:906:944b:: with SMTP id z11mr3858668ejx.151.1556215056839;
 Thu, 25 Apr 2019 10:57:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <20190425152550.GY12751@dhcp22.suse.cz> <20190425153138.GC25193@fuggles.cambridge.arm.com>
 <20190425154156.GZ12751@dhcp22.suse.cz>
In-Reply-To: <20190425154156.GZ12751@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 25 Apr 2019 13:57:25 -0400
Message-ID: <CA+CK2bDLkSTdrYx+zth9=EJxigQR1-nMt52avt7-NpguAWwoVw@mail.gmail.com>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Michal Hocko <mhocko@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, rppt@linux.vnet.ibm.com, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com, james.morse@arm.com, 
	Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > I gave *vague* memories of running out of bits in the page flags if we
> > changed this, but that was a while back. If that's no longer the case,
> > then I'm open to changing the value, but I really don't want to expose
> > it as a Kconfig option as proposed in this patch. People won't have a
> > clue what to set and it doesn't help at all with the single-Image effort.
>
> Ohh, I absolutely agree about the config option part JFTR. 1GB section
> loos quite excessive. I am not really sure a standard arm64 memory
> layout looks though.

I am now looking to use Dan's patches "mm: Sub-section memory hotplug
support" to solve this problem. I think this patch can be ignored.

Pasha

