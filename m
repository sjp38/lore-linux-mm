Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D82C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6273F20717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:36:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="kV/m+79j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6273F20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 639746B000A; Thu, 25 Apr 2019 12:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60EDC6B000C; Thu, 25 Apr 2019 12:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B1C06B000D; Thu, 25 Apr 2019 12:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5B636B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:36:56 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id z21so461403wmf.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:36:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UF9yiYSdp+bqbl4vCjqwOikVi1eCtCz+Zg7/2WDARJw=;
        b=UJXv2n/jUBd8TfRX4M2W9HUdPpHo7rw3rDPxZ2GEOQOjgmRZp30kVdaItNdSDVerms
         iNC+tDdL0b4ZSKDJhC3XAYVXnhwMVo9R5V2amWpXL0SlyjdDq3gBX/BmE7UbzgUf5drV
         lkU7b9PQdDDICZRw053ORY++YZiqJwHQegozSF2eUAvLI5scQTTiueOeNoNNI6eIvs8X
         /fj0FYl98OmVE5MRh3A/HGnmUdDg63W49MxREWw6MC5KK7nOUKqBQWEQ6VjTdZ3v2E7g
         AiT1ztqyLSHJNPAqcOgxv5pgrfu+D0/I54R2OO1YGkyINYXz3WCqC6rE8joAWbZFJdsH
         wnUA==
X-Gm-Message-State: APjAAAWhayDHdYQMo3pawwbYNdQeZptYRgqUKhm8IX/YXvafqse3IeXp
	AASX4EAO4yhBFlTGFo63cdcJBe8VtyLu6+iFPNSclJFd+gSyihk4SFbYwkbT28M7bMwg43S3wJf
	RAam4jr5EKE0xuaAzXBh6lt9NAJivHxIds11WFWDYEY41BK5v0dqFaFVuLAMvl0XVtA==
X-Received: by 2002:adf:fa47:: with SMTP id y7mr27959129wrr.27.1556210216498;
        Thu, 25 Apr 2019 09:36:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa+atYx4Cer8nBHVMRe5gBlwfnU8ac77xKcA1QPunSgvuVyYjh61BsDjGS0QmoZdBydPFQ
X-Received: by 2002:adf:fa47:: with SMTP id y7mr27959095wrr.27.1556210215768;
        Thu, 25 Apr 2019 09:36:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556210215; cv=none;
        d=google.com; s=arc-20160816;
        b=B/IjlAnzfhUshL1KlI8dMnZOUJHYKug/QJXHaxuyVpuQfahior7sayGBD7CzbrEQoK
         9NryjtE8NFR+Leu0tgPRa/wTKMKHVCvUge5bwRf5jUktGwrHvfmdaXOdP/RE4NfIffKa
         MKud4cTuEJXfvM8Iw7dsGsrXPOaFvkVgbmL/MULHf5C6DcdtiYP8UUzw3NaDLFwS+Wq/
         hviU5y/O9wzFX3tOZ99TK32rBz6CI26eqxuFGeVXehmGxzMdY4RRh2QeA6FkaEks+GEa
         EHSxfzP3CWTW8e7ltiwwHK/JdBfAP5fA9FUi9PhK9MpUu5a+GmDH+qG1pJAKHS8fatVN
         mS7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UF9yiYSdp+bqbl4vCjqwOikVi1eCtCz+Zg7/2WDARJw=;
        b=tt4HPmGy0FK7b0drhyi5VEYRCQtd7vdwmg15+vlx0myAkinAN7VDhXie/Dn5CYhY77
         GPEvmBn4bKCBEUHyqHYaIic/xKadRDj0GOdcWdwscKyOyJBWOIP75TxaNBjD9KtbRXZc
         l+zmM4agypu/YU5Ksd8LQ6jELC1dOfzGdCy8rJtyXu/glO+qRNDTv7td9iU9gbali2lv
         sAPQ3fhNxIbtyxD7zjApir+vhOzqXMcb5OjpK82In5mgqY64MIEPEfrJcU5u+BZ6t8zR
         2UDS9XXg2W+QqcgTcW6HbdoeiRHPVQ225ReKXifhCJGf+wB7yV/YxCHTfYaMY8W4k983
         BqIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="kV/m+79j";
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id l5si5264089wrf.358.2019.04.25.09.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 09:36:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="kV/m+79j";
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2F0E43001D86563D61B131D5.dip0.t-ipconnect.de [IPv6:2003:ec:2f0e:4300:1d86:563d:61b1:31d5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id DE16A1EC050B;
	Thu, 25 Apr 2019 18:36:54 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1556210215;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=UF9yiYSdp+bqbl4vCjqwOikVi1eCtCz+Zg7/2WDARJw=;
	b=kV/m+79jALQI1SIUHyZS/iVqIPFCNzfSqxYTx3FPj4F0x4oPEWWLq1yatQ1q0R9G9CI1gJ
	tWVAYj0QEqtPb3+EvsUr2mlR6ftcBWLTsIr9n9qBg8kWKvyMHtUV40eIKB4wJw2NTVkaZF
	2dIrXfbNbKnxIPdylPQVnVI8Fj9YuaM=
Date: Thu, 25 Apr 2019 18:36:50 +0200
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v4 04/23] x86/mm: Save DRs when loading a temporary mm
Message-ID: <20190425163650.GB5199@zn.tnic>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
 <20190422185805.1169-5-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190422185805.1169-5-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Subject: Re: [PATCH v4 04/23] x86/mm: Save DRs when loading a temporary mm

s/DRs/debug registers/

On Mon, Apr 22, 2019 at 11:57:46AM -0700, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> Prevent user watchpoints from mistakenly firing while the temporary mm
> is being used. As the addresses that of the temporary mm might overlap

s/that //

> those of the user-process, this is necessary to prevent wrong signals
> or worse things from happening.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/mmu_context.h | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

