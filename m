Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A58A7C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 717362258C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 717362258C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA886B0003; Tue, 23 Jul 2019 06:16:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05A746B0005; Tue, 23 Jul 2019 06:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E66888E0002; Tue, 23 Jul 2019 06:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0626B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:16:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so27965870edu.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uA1+CDRq3YimgpJMRLOHGnGjnaKUGkw4/Oh++uAfZLQ=;
        b=ZWgpHs79Fb3op7wonvb4cCRFsgLyySgQ2+1TBC//fgypPpygjj0+f/6A5R9ghfFx5C
         NJtEN+OU4ktCp6vcxzssVN+GiJoqidjiRa940igqN9oo/i3YVJ4XSdSmZAbtjzXpyfx3
         gfhMdadX63kNC0EDAcGDgb1cOHMF4Dwc5g+p1QjzYYDm9DTYnVSguj5hknBMUblHwOQY
         j8Gm2ibg+l33Nu0nXEyGcNMSIXkJy6jRXV8IZ/2zQs2+Sv0rUkV0N/RtKEO+9vJLYgch
         VCpt8SdGutBu/sguCwR96bxPcRoZ7A+4oB0Mmkf+DWoJhE7iPrprWunf8PY8HLN7J2pc
         m9Mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXBDbho6npp9NomGZkC7lU1KKvHWkVtyP4ITOukJAwniIhLNpiN
	0h4d3PfvJ3fcobkiM7Rk2Oknes7snKM//WyrGOahUpLe77aUCwY2LtHIlC9bSMB3dQkKoUs0qRB
	rVvRFj0KCeo6I1SmTwPN0W5qj82Gbi9G6BVG5I17Rw8SsgjERelWVaxd3Xxuis4r0gg==
X-Received: by 2002:a50:a56b:: with SMTP id z40mr63618004edb.99.1563877006200;
        Tue, 23 Jul 2019 03:16:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykzHi65k4ss2Umj/dab/0nH65vEJzCyVRx5kvokjdB1LUGUEonElps01iiDIjFEofBFFpG
X-Received: by 2002:a50:a56b:: with SMTP id z40mr63617946edb.99.1563877005521;
        Tue, 23 Jul 2019 03:16:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563877005; cv=none;
        d=google.com; s=arc-20160816;
        b=z2xMyau3TNLf7H9L/DBKx6dbrGZKlL5S9oy7Gs27i+cycqCbIsGXrw+0SML5J/H1km
         IosKRnlRuk2wRGtzhOeMZ2dPqwH/fiork0uQN0ZhhZq5EPcyFwOH5SbXkc9DBeJWkkTj
         IlpBEcaGmY2zYLOS6Ut1Xud/b9kMHFkK+M2RbjRZaQNuMl/plmnhdsQCNcGv0G48T9w8
         CP8SjqWa/vB2yWNoMrsxdcxbsLagCL2z153kdm//iJCZ29TVCOn+gIwjq9QphPLwKMZP
         n6V7BUr5tT4Tp7PG5nKOrIRsRwikk3fXisj4Nh1lXjlhaqgBQShaML94ZGqmAJkAKi+o
         75sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uA1+CDRq3YimgpJMRLOHGnGjnaKUGkw4/Oh++uAfZLQ=;
        b=cfmpkZgm/csIZUTDzIe2UZox2N5ZOmO/mydZw9j9g/xHf0hTKBKl0rk7KkpjOJB3o7
         jiG1QPCX7B9yahuYJoZ8e7txVEAMnXXQGyZFNvVZssalstkm3D/rM1+p1RRtlZyR+B5O
         8vgn1m1XyPyeHUKxsJueIxI2OpXhUf6JizR+QUh4omv5bSlmkg9PRXI6S4q3ntdZga/t
         qYEIAZhzQHYtQhUxhPVfYQuoxpOfn94T8sl8puxsFDMluQextnz/Y9NGIIVUc3SKBxz0
         rzDmxx2TiEwnrRJlwwdY7aPMo7sVg0vDfXzSoNtam1IcN9GP75mTWKwZkSzYAudW3npj
         TjhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w29si6630798edw.81.2019.07.23.03.16.45
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 03:16:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B04A9337;
	Tue, 23 Jul 2019 03:16:44 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4057E3F71A;
	Tue, 23 Jul 2019 03:16:42 -0700 (PDT)
Date: Tue, 23 Jul 2019 11:16:40 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
Message-ID: <20190723101639.GD8085@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:41:49PM +0100, Steven Price wrote:
> This is a slight reworking and extension of my previous patch set
> (Convert x86 & arm64 to use generic page walk), but I've continued the
> version numbering as most of the changes are the same. In particular
> this series ends with a generic PTDUMP implemention for arm64 and x86.
> 
> Many architectures current have a debugfs file for dumping the kernel
> page tables. Currently each architecture has to implement custom
> functions for this because the details of walking the page tables used
> by the kernel are different between architectures.
> 
> This series extends the capabilities of walk_page_range() so that it can
> deal with the page tables of the kernel (which have no VMAs and can
> contain larger huge pages than exist for user space). A generic PTDUMP
> implementation is the implemented making use of the new functionality of
> walk_page_range() and finally arm64 and x86 are switch to using it,
> removing the custom table walkers.
> 
> To enable a generic page table walker to walk the unusual mappings of
> the kernel we need to implement a set of functions which let us know
> when the walker has reached the leaf entry. After a suggestion from Will
> Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
> the purpose (and is a new name so has no historic baggage). Some
> architectures have p?d_large macros but this is easily confused with
> "large pages".
> 
> Mostly this is a clean up and there should be very little functional
> change. The exceptions are:
> 
> * x86 PTDUMP debugfs output no longer display pages which aren't
>   present (patch 14).
> 
> * arm64 has the ability to efficiently process KASAN pages (which
>   previously only x86 implemented). This means that the combination of
>   KASAN and DEBUG_WX is now useable.

Are there any visible changes to the arm64 output?

Could you dump a before/after example somewhere?

Thanks,
Mark.

