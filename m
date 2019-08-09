Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC026C41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:45:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 995A021743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:45:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 995A021743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 328276B0007; Fri,  9 Aug 2019 07:45:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AF816B0008; Fri,  9 Aug 2019 07:45:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150F26B000A; Fri,  9 Aug 2019 07:45:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B79D96B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 07:44:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z2so1170689ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:44:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4ir+06ZMiRgsaxScI7Y16ZAMU9XUAFE7C2jwTSgBmM4=;
        b=GHEcqpTGO7rjNyv0F5SZB2r0Z6Kz1OoMYnEEudSjAGzOO9/M76hCiVAP6Wno1Ir6M+
         uNse/PEtp8mrUhUWy+AqetC0VuUszolfuXnEWjJbT7RVETrlrJVK+Jbb7vlP8Lwrq+Ax
         9o3BGq7Oxv9Rskd0vSLUqIuUxm48z71wf6eI5TVRXzCOzV2PQDUCSVFRuRUCtp0u7vxv
         o2n5KAe7+z6aJkouvOSC8vq0Pv43jooKa52sSPYDWG5tlDgvqoXJ+S0MEXbzHEnO0r0N
         OQyQ/ZYAIiyiaFEaj/TaPbhOSjyJz5YNhYlx0kVL5hSx+eI+f8PnoeiOeG/NEt1okJGP
         z04w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXBA0NgvqdkbVTJ5vqh/IEr9bokN5C6sZPytVQpVOYFOdBK7M7x
	aPaRmoCW0vDoI4L69YC+ktzP3NxltyskYaogC2xFnQxRLLKhaFHanLGlb/T41WlaC9fvuEDk1lr
	TGSsO/XozkkFBhFZapGkAV7QT553i5opqr9ZuOH0DGMdIb3DDGFHiG4PHpNaM7OldTQ==
X-Received: by 2002:a50:8b64:: with SMTP id l91mr1833179edl.258.1565351099319;
        Fri, 09 Aug 2019 04:44:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZp2qG0j0uHr1Pwtz+vi4oxO+Bq6VLht+WWR+trIQvkKHU6m3BZYo1QbuLnvBsqzQ9C5ds
X-Received: by 2002:a50:8b64:: with SMTP id l91mr1833131edl.258.1565351098647;
        Fri, 09 Aug 2019 04:44:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565351098; cv=none;
        d=google.com; s=arc-20160816;
        b=Nr+f1fhNnzSiv6Ouhcz5ODHLH/VArrGU64y/qcdjE7jVhH+B3vqeQ6noIzXnH1qBWY
         yNXB0IkAE1U39Rzj2tVrlYYQX5YwycasWxEm7K/ZchTxdCp6LRzl6QrRGRkiX370BgQ/
         0exIYCj/8kNqP76R/CTcZu6HJFSqB+Ih+PqUVG5u190pm4Hdkt7eWbMsDOBD2e0otR/X
         XPGKHOJVo7iUKSdxKtVLh6iAtriaYxmdxbG/aP1rU6tlL2ABRmQ1Tasj7rCc8blyWk5H
         NgZpf9jepdinV3i8xVMxDZceicppBHeMiV5r9sX4eRy5EWjA7uExONvfBkqBrokX/TQL
         UFrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4ir+06ZMiRgsaxScI7Y16ZAMU9XUAFE7C2jwTSgBmM4=;
        b=ZmlkacrtVJABOHuS5rVOlSwhBf/moZVwhfzPMmMxQ2gm91hfENR9sZn1c8de3wdjfp
         f/DndYyX/pJ+B0oi1Z2I7bHTl/qFC4KWS5ng5F9eNXjQ/xDaTACBpmXcqBd5lBrrdJcW
         +4/Ph4jb2nOb3Q794rsI7VjA9qfJDyPZaiA4J44jMY2yV6kebYOA3epV6td8vexd81Qg
         jYb8ZKTZohCB+s0piDgmTCh78TPqaJ/c0rd5U/cEdQNY8VNRNZYTFu4W5HkgfwKL6tQx
         WJN8iAgQo54pUQYeoczGeDgoENoDRCnqJJrDUOwKAi0Vsf62i3X7NKtWIUumVqafzZF3
         Gd2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v21si1386475ejk.387.2019.08.09.04.44.58
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 04:44:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C12CD1596;
	Fri,  9 Aug 2019 04:44:57 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1DD783F575;
	Fri,  9 Aug 2019 04:44:53 -0700 (PDT)
Date: Fri, 9 Aug 2019 12:44:51 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>, Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page
 table helpers
Message-ID: <20190809114450.GF48423@lakrids.cambridge.arm.com>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809101632.GM5482@bombadil.infradead.org>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:16:33AM -0700, Matthew Wilcox wrote:
> On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
> > Should alloc_gigantic_page() be made available as an interface for general
> > use in the kernel. The test module here uses very similar implementation from
> > HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
> > needs to be exported through a header.
> 
> Why are you allocating memory at all instead of just using some
> known-to-exist PFNs like I suggested?

IIUC the issue is that there aren't necessarily known-to-exist PFNs that
are sufficiently aligned -- they may not even exist.

For example, with 64K pages, a PMD covers 512M. The kernel image is
(generally) smaller than 512M, and will be mapped at page granularity.
In that case, any PMD entry for a kernel symbol address will point to
the PTE level table, and that will only necessarily be page-aligned, as
any P?D level table is only necessarily page-aligned.

In the same configuration, you could have less than 512M of total
memory, and none of this memory is necessarily aligned to 512M. So
beyond the PTE level, I don't think you can guarantee a known-to-exist
valid PFN.

I also believe that synthetic PFNs could fail pfn_valid(), so that might
cause us pain too...

Thanks,
Mark.

