Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCE19C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:36:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AEB121019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:36:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="IcABX1nM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AEB121019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 082806B0010; Wed, 12 Jun 2019 14:36:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 033D56B0266; Wed, 12 Jun 2019 14:36:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E631A6B0269; Wed, 12 Jun 2019 14:36:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA9786B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:36:00 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l11so15307124qtp.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:36:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Ccd2Dl/s5BEnRCE+LL0hkZ64UWDD7pEB/PZyv8yO8ZY=;
        b=E8lAGzDXMSXyePt62OGFGaxqrfsJDGRB1LHw69EQQ66AMk+v0brhVVMWyAcgSBzha3
         3qTju55vHjdkv5mz1DCYCJTCiIHFAdOnSPtaZqgodvLBnsp5covGppJ9ZShAHErh0xw1
         R7RfVr67AhYOrfb/JQQpycHDQrIMMJbOh6+JB7B1L8GhCqxU/VePBT6UKqm7Fy7bFQjI
         7/dntnSL7P0IXXaY5nO5tGsL/F5Y1q8Vkdw+5shhyCtNs4pAhkQdf+Cea3jiCmp9zSaB
         58zWahnbGNgY3yTe1NIdSjvnpT80ejlblyvBeNGAUDhWGOV05mGHspuz0ebcun3zefgu
         txaQ==
X-Gm-Message-State: APjAAAXt19b7WIe9XejC2mi3MMvDEri52abB2W6az8X1+EQgxQlj1jJl
	ycurMwRjBXyG44v7BV/aQ6osLdbmDbQVRAGnalmXadE2Qy3EY5ePX/mNemW2OQMBD52xTozOiHj
	4CDjvDgi7kZQnQR0WTL6O4GAPJpEVbPXlDbKutPFDb1jcyuQsxp02PDIH4Ghgns9Crw==
X-Received: by 2002:ae9:f303:: with SMTP id p3mr1981279qkg.320.1560364560502;
        Wed, 12 Jun 2019 11:36:00 -0700 (PDT)
X-Received: by 2002:ae9:f303:: with SMTP id p3mr1981245qkg.320.1560364559729;
        Wed, 12 Jun 2019 11:35:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560364559; cv=none;
        d=google.com; s=arc-20160816;
        b=JTprbyggr8zi18RThQkP8m9fbCpOA4s+oSVCQqKr984/0+V8qTIn8Eev6oZ3CQKSVs
         uHzQMSTqvCOAWfWPdNg33OhpqxRMdtV8rQJCC0oJEQppq3DhnffPD2qmvx0R9m7I73Mm
         xHNYFddHVBwrf7+9LKuHuZtMr5wPD1aKQa85c9psho5WieNseD/bbVy05HKdp8ubM9wF
         3mNw0BlzTzm5Yx2F64e9aWzYuNlRXeq7vxbtaeu1ObauNE2NLVUvo0HCwV5BgUoJwP2C
         f5kfF7Hf1zl31GsUAFq4sycXBlpwhTiAWntvtn/Wmqp9WiZ7JxK9FyUDJUgeFjHtWCvQ
         cmVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Ccd2Dl/s5BEnRCE+LL0hkZ64UWDD7pEB/PZyv8yO8ZY=;
        b=gnL17X6IFsEz3M6pqucrUFgF71bO1K2z9hseSjmHSjQkgQugQKU0cvH/2aTgeVhtX1
         O8mffR3LtEb+HKbGfBTEv6vrG5qYKdIGEAYwX2938yX2aaMlbhzfUfUYt6KTfNTmEuML
         7fNVNTtZnmv+zYpoRRzWq0pGOG7yiGzROt4OioDReQBV5zu5JcHVN9PxjuR+cBBAObn4
         +146Zq7oZy0ER/rwmbV6jGK5/t3Yuc32ym0cfp5xn87bca2NLw0f6e9ImvqXBTlk3RuH
         xyVwiUWy78jQsFBPTIZBi03VJWm7ZKKPx/neaxSuQ6nExl3PklqGvC2d13dKK5xIpl71
         Iciw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IcABX1nM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor115972qvv.39.2019.06.12.11.35.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:35:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=IcABX1nM;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Ccd2Dl/s5BEnRCE+LL0hkZ64UWDD7pEB/PZyv8yO8ZY=;
        b=IcABX1nM51p2QrQVsut+vh/j10d5dr6geQ+a/RrmE6DOHq7udCPilWtmRYD99j0boR
         ov5Ysub7+GqF4lbZDxDthsXnWeXk+ES3UVFuSCse5kakCEymFY4P7BJeaa1eqMTm9m4J
         a+/2xER8DdWKm0/0yHAUhnmEJWAiez71uz/DfX4C+ZMkDAyMe9n6LHO40E10deKj4zJN
         Wel0wmmIihoR/AvHw5HUgRWq+VZtm2o2vy9xdx+v9Lo1iXmV5/ZbXP3K7XF07He5wGRh
         eTLt9p7wJXVFha1pn5wg6b5vpyG2Z/ZLgk4Y4y0kGDJ+N6XDcakHacAueyHQQONRObHL
         LFHA==
X-Google-Smtp-Source: APXvYqxVhJgr9VMk6UTsEjd7fGkQxdE+ShlHGLoBskD9CcIJfDIiuN/yiHxzbH4RhCcTZeh0Ja2AHg==
X-Received: by 2002:a0c:fde3:: with SMTP id m3mr136658qvu.205.1560364559359;
        Wed, 12 Jun 2019 11:35:59 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t67sm224679qkf.34.2019.06.12.11.35.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 11:35:58 -0700 (PDT)
Message-ID: <1560364557.5154.2.camel@lca.pw>
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
From: Qian Cai <cai@lca.pw>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, 
 Andrew Morton <akpm@linux-foundation.org>, catalin.marinas@arm.com, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, mhocko@kernel.org,
 linux-mm@kvack.org,  vdavydov.dev@gmail.com, hannes@cmpxchg.org,
 cgroups@vger.kernel.org,  linux-arm-kernel@lists.infradead.org
Date: Wed, 12 Jun 2019 14:35:57 -0400
In-Reply-To: <20190612065728.GB4761@rapoport-lnx>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
	 <20190604142338.GC24467@lakrids.cambridge.arm.com>
	 <20190610114326.GF15979@fuggles.cambridge.arm.com>
	 <1560187575.6132.70.camel@lca.pw>
	 <20190611100348.GB26409@lakrids.cambridge.arm.com>
	 <20190611124118.GA4761@rapoport-lnx>
	 <3F6E1B9F-3789-4648-B95C-C4243B57DA02@lca.pw>
	 <20190612065728.GB4761@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-12 at 09:57 +0300, Mike Rapoport wrote:
> Hi,
> 
> On Tue, Jun 11, 2019 at 08:46:45AM -0400, Qian Cai wrote:
> > 
> > > On Jun 11, 2019, at 8:41 AM, Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > 
> > > Sorry for the delay, I'm mostly offline these days.
> > > 
> > > I wanted to understand first what is the reason for the failure. I've
> > > tried
> > > to reproduce it with qemu, but I failed to find a bootable configuration
> > > that will have PGD_SIZE != PAGE_SIZE :(
> > > 
> > > Qian Cai, can you share what is your environment and the kernel config?
> > 
> > https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> > 
> > # lscpu
> > Architecture:        aarch64
> > Byte Order:          Little Endian
> > CPU(s):              256
> > On-line CPU(s) list: 0-255
> > Thread(s) per core:  4
> > Core(s) per socket:  32
> > Socket(s):           2
> > NUMA node(s):        2
> > Vendor ID:           Cavium
> > Model:               1
> > Model name:          ThunderX2 99xx
> > Stepping:            0x1
> > BogoMIPS:            400.00
> > L1d cache:           32K
> > L1i cache:           32K
> > L2 cache:            256K
> > L3 cache:            32768K
> > NUMA node0 CPU(s):   0-127
> > NUMA node1 CPU(s):   128-255
> > Flags:               fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics
> > cpuid asimdrdm
> > 
> > # dmidecode
> > Handle 0x0001, DMI type 1, 27 bytes
> > System Information
> >         Manufacturer: HPE
> >         Product Name: Apollo 70             
> >         Version: X1
> >         Wake-up Type: Power Switch
> >         Family: CN99XX
> > 
> 
> Can you please also send the entire log when the failure happens?

https://cailca.github.io/files/dmesg.txt

> Another question, is the problem exist with PGD_SIZE == PAGE_SIZE?

No.

