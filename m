Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074A0C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B50021904
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B50021904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F6B38E0003; Mon, 18 Feb 2019 08:45:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A4FE8E0002; Mon, 18 Feb 2019 08:45:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26D7C8E0003; Mon, 18 Feb 2019 08:45:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC5BB8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:45:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d9so7167177edl.16
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:45:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=a8vWFblK2cLV+Lp2qiqIwo5e3K3WS6p/1t8Ul4QwzZM=;
        b=UZ6JlqCn8uuNGJ4QOdR44Yu88cy9k3SorVPpNB1SWXhERMI9smnHSQKS5Y1DkEdB5B
         5yzv/VL3A7kaf3APaom32kBboqlncysa3Ne+R1O5/Wv9N5dJYaRWkEjxrkqbKVCoXHZc
         4qVu1ijyk73jJixAOFQMyiu8hNBNxFL14Med9hWKNRwITh/UXZS7xaVo76skERk6VotJ
         W5zCHgI8CasT2v7bHQWjAxpiJokgplJha1wG9mtY3OTtWqoivlWT5NSw7mTTNLzI/GGp
         sthMdCup9b+lAni9Jna7fkU1oNvwZ5u7+gVedtSazZ88kCYqbru7qPVfrp+l1NZljxrx
         A0zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuaZFONiXkycIzIDf5n4tx0VCY4MpIaeQdsL+M+MF6kEqf+sRtGy
	2UNDqAbmsNbxFInTPVifohe3Slb6Few776EC+7R0fcFc3Sik+Q79GmdMpdiOo06OwrLAjMmgKIZ
	MMi998ywX6rQ/DSfARMxa0dNqa5fwCRc8CoS6Yr/t8f7PNq0KUo1Xz1yohRvCPoO10w==
X-Received: by 2002:a50:b49b:: with SMTP id w27mr2918258edd.54.1550497527322;
        Mon, 18 Feb 2019 05:45:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZq5xuIKceSKOZ/bzwsIkDcYTup6PfYfdScTXvH8m+bPn5+7hbHPHQaHCMgCXfnrnu/kKA3
X-Received: by 2002:a50:b49b:: with SMTP id w27mr2918200edd.54.1550497526313;
        Mon, 18 Feb 2019 05:45:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550497526; cv=none;
        d=google.com; s=arc-20160816;
        b=ofzmpf0YJNc5VBG99kwN/AYijdkzbN5b6mpKxeZVV8PRjAdUo+fRunUGOWGvYBeovy
         GiIIyU1+P64MbQ2Djg782CRMZF43zdKU4kjG/StJ5NmBYdJ2sGHMGt/rsX/UNX2ZXfyy
         LzJdQEzS+dgWn9ZRFRx+WzOi04KzZmLYL7nosJmqGZFrMN+avGygZ6aIYy0S6lNNZlkw
         scsT7EHbTsmonHBai05y93QFaBf3PX13kfK8mK5NNpC2x06vNTDKQSPTHPLa82aACmii
         grxMwcFxgTI/gwa01tH0cxxtPAtH5pXTIQHIBICzvnymWpA4Ad7doB1hjTMF7g3o2dD+
         hnHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=a8vWFblK2cLV+Lp2qiqIwo5e3K3WS6p/1t8Ul4QwzZM=;
        b=WCYyTvYG3ugZKYIvpHMKLNujDFVJqPODKKg3cEim8dJevETgOovYK6Y3HFWZPprNfT
         Gc4Ek3eQ7iJ8c72JnXPzn3anOVUQFSSiK+CpgF8VB1vGKml83AUJqfFmJHxgYhaDEp12
         g+oDHZp3uQPlSkusqIoCVTaqMxG+yI2F8+EDxv/wxbpv+n/ODdIcgqRR3/y4BFzW3W7f
         ZFRpZHVU1GXTNdtnfz/8rqPPmX8FeMKKDwHV6q/1plcfMXLyJ5R0/3fti1S7RwEVM5sn
         L5HdpAUlMZqFktA4hVBwOTt3OQF/UfNjGy+6tJiZoF04LRO5gks9fzULU8v+4bVEuK+S
         1vSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e13si30531eds.130.2019.02.18.05.45.24
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 05:45:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 290FCA78;
	Mon, 18 Feb 2019 05:45:21 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2FF3B3F720;
	Mon, 18 Feb 2019 05:45:13 -0800 (PST)
Date: Mon, 18 Feb 2019 13:45:07 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190218134507.GA9603@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218112922.GT32477@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 12:29:22PM +0100, Peter Zijlstra wrote:
> On Fri, Feb 15, 2019 at 05:02:22PM +0000, Steven Price wrote:
> 
> > diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> > index de70c1eabf33..09d308921625 100644
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
> >  				 PMD_TYPE_TABLE)
> >  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
> >  				 PMD_TYPE_SECT)
> > +#define pmd_large(x)		pmd_sect(x)
> >  
> >  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
> >  #define pud_sect(pud)		(0)
> > @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
> >  #else
> >  #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
> >  				 PUD_TYPE_SECT)
> > +#define pud_large(x)		pud_sect(x)
> >  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
> >  				 PUD_TYPE_TABLE)
> >  #endif
> 
> So on x86 p*d_large() also matches p*d_huge() and thp, But it is not
> clear to me this p*d_sect() thing does so, given your definitions.
> 
> See here why I care:
> 
>   http://lkml.kernel.org/r/20190201124741.GE31552@hirez.programming.kicks-ass.net

I believe it does not.

IIUC our p?d_huge() helpers implicitly handle contiguous entries. That's
where you have $N entries in the current level of table that the TLB can
cache together as one.

Our p?d_sect() helpers only match section entries. That's where we map
an entire next-level-table's worth of VA space with a single entry at
the current level.

Thanks,
Mark.

