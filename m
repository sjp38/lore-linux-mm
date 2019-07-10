Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E2B9C73C6D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 05:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9357F20838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 05:59:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9357F20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEDA38E0068; Wed, 10 Jul 2019 01:59:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E448E0032; Wed, 10 Jul 2019 01:59:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8C2B8E0068; Wed, 10 Jul 2019 01:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 569838E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 01:59:03 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id m2so289054ljj.0
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 22:59:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=PDwHUB/U1Dx9d92PPEJemltmsVvg53siDRKnpPtq0As=;
        b=TMeHz1vZ07dJ3LUsF+Hi3bMPAR+QbusKEk4gikIK4BgW8R8mJfQHPRi+4DfqMhFYdE
         zR9kkUFEJTdBjXT/ITYeJxU/yF4FtxJezBsEssfkhwzLtzpxjpS0WH3OJ8mGdd2bT9t/
         tAt8o/toAjlmmqWHD3j2EK/8meqMNFMhexEVDX11scn5jsKDqYD/DWquVidCDmdIBbuW
         ND6Dti8vUQ89GK/pjwoXZsDhJ+duDd2/9pTtp9odh5UNccjkkoZR9IRZxUpkWH6TAeO+
         9Yr1PbD44th+fYc2KEKS0Z/ngBx98ChyC2Bi7kwTbMzrdxfvZ2KfWjviZSq/uf9BxcJ/
         szVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUwluTYh//XIayGSUeq8Q9cEgLeEIdukP4r5sSaitMffP4ZZ/47
	sYKxOQXOpmYRV3om/Ie44ScZsMnu/cCum2rNR+YZIeyU+S7rwv9vygfr5j2HYd0xbnbfTL4JIw+
	05gdUUeUE+8PE4O7nmS0/i7/3uS82tBtJx57iEQYcdXr3Mhr9BsN58X12O4vBQRVk/Q==
X-Received: by 2002:a19:ca4b:: with SMTP id h11mr13139999lfj.162.1562738342783;
        Tue, 09 Jul 2019 22:59:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZcyWZLpH8JlPMC8DnOMYnKopf3V4HNJEVekg5nmWp8A6j7XdGx7byUuCUFwF5EJipsumN
X-Received: by 2002:a19:ca4b:: with SMTP id h11mr13139953lfj.162.1562738341986;
        Tue, 09 Jul 2019 22:59:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562738341; cv=none;
        d=google.com; s=arc-20160816;
        b=scNLGRpMzIAsnB57kdrj7OI2vRbmBpgNsl/ZVK0lCe882hsw2NmrPanTo+GpnxDgGF
         tMYfPvFCL89dCBgQZhvFNE4WOhpsDbW2DbFVeThiStQFhR7Q7rgqlW2yc/GSbU8lfLqj
         pQW7kvhaLfVtHi21UUk4rNuO+mzJ1L3d3tBFgLrbXpNE2sECFeA8lYrHQgh72TOTdhWH
         KCSKyk7tIHte8vbp55WnEkDBgkGvfSgyvr8OcsPpsBsFr7YjnvP89ao1Gjx72yIFTjng
         goH0ggXXiTyneA+L2Sn6f7xCNfAY+WNv+LINWxmZQewFZkXHrwkdLypKZ8DoilDw8jWV
         CLJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=PDwHUB/U1Dx9d92PPEJemltmsVvg53siDRKnpPtq0As=;
        b=CCMLlQkklRL+V7/em5uX0cwVkJAniDXun19C5eiAy/kePghgPCMu2Qfmv+oy3/x0jM
         PsTgcwmR/OpZw6zo6kZkZbZk6hXdOqXmJQ7od7wLUzo10AkcpZ4FI7DQhcPDKAhkdycO
         WR+UB/rbgOrwG8wpn9O/hiITvsQXvmsDLFmotgu1lC1FtYVmTlxEkZ9mrrUteLl42xW5
         AFweg/sEARKrrs336qSxRizJdfdlTXgykxWjOJRrHX5REjD0oBv9m//gCqP4N1BR0V3i
         UiNx+g5teeeAkF13vetjqiiJ8mcG2qfFTPMGggFC8JqND5zVzjP+PiGaOvbEnX2IiVx3
         x6Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id q16si1077282wrn.437.2019.07.09.22.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jul 2019 22:59:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hl5cV-0004bB-Pv; Wed, 10 Jul 2019 07:58:23 +0200
Date: Wed, 10 Jul 2019 07:58:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
cc: Catalin Marinas <catalin.marinas@arm.com>, 
    Will Deacon <will.deacon@arm.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
    Pavel Tatashin <pavel.tatashin@microsoft.com>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
    Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
    Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    "H . Peter Anvin" <hpa@zytor.com>, 
    "David S . Miller" <davem@davemloft.net>, 
    Heiko Carstens <heiko.carstens@de.ibm.com>, 
    Vasily Gorbik <gor@linux.ibm.com>, 
    Christian Borntraeger <borntraeger@de.ibm.com>, 
    "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
    "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
    "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, 
    "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, 
    "x86@kernel.org" <x86@kernel.org>, 
    "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
In-Reply-To: <1c5bc3a8-0c6f-dce3-95a2-8aec765408a2@os.amperecomputing.com>
Message-ID: <alpine.DEB.2.21.1907100755010.1758@nanos.tec.linutronix.de>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com> <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com> <alpine.DEB.2.21.1906260032250.32342@nanos.tec.linutronix.de>
 <1c5bc3a8-0c6f-dce3-95a2-8aec765408a2@os.amperecomputing.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hoan,

On Wed, 10 Jul 2019, Hoan Tran OS wrote:
> On 6/25/19 3:45 PM, Thomas Gleixner wrote:
> > On Tue, 25 Jun 2019, Hoan Tran OS wrote:
> >> @@ -1567,15 +1567,6 @@ config X86_64_ACPI_NUMA
> >>   	---help---
> >>   	  Enable ACPI SRAT based node topology detection.
> >>   
> >> -# Some NUMA nodes have memory ranges that span
> >> -# other nodes.  Even though a pfn is valid and
> >> -# between a node's start and end pfns, it may not
> >> -# reside on that node.  See memmap_init_zone()
> >> -# for details.
> >> -config NODES_SPAN_OTHER_NODES
> >> -	def_bool y
> >> -	depends on X86_64_ACPI_NUMA
> > 
> > the changelog does not mention that this lifts the dependency on
> > X86_64_ACPI_NUMA and therefore enables that functionality for anything
> > which has NUMA enabled including 32bit.
> > 
> 
> I think this config is used for a NUMA layout which NUMA nodes addresses 
> are spanned to other nodes. I think 32bit NUMA also have the same issue 
> with that layout. Please correct me if I'm wrong.

I'm not saying you're wrong, but it's your duty to provide the analysis why
this is correct for everything which has NUMA enabled.

> > The core mm change gives no helpful information either. You just copied the
> > above comment text from some random Kconfig.
> 
> Yes, as it's a correct comment and is used at multiple places.

Well it maybe correct in terms of explaining what this is about, it still
does not explain why this is needed by default on everything which has NUMA
enabled.

Thanks,

	tglx

