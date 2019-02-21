Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06364C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B26B62070D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:57:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="wwPRWoH7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B26B62070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 521D98E008B; Thu, 21 Feb 2019 09:57:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F7478E0089; Thu, 21 Feb 2019 09:57:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E7B98E008B; Thu, 21 Feb 2019 09:57:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEE738E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:57:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b15so1045087pfo.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:57:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T6VBBJYyKGf9Yt7Yt1V87f/1+l66aJ7Oi3kjsALTg5U=;
        b=gsApT414LBf1XAFoNmAwd81r+ZyQj53jjlJ1OsSZqHF99YkUrLwUvEo8EmYsWKcpAO
         noGZHKGGRp2PULyfkTEmWsheRhjlS5OSSaDPdNFjvPqldvYrekZGM7yl1t0LUxbOFOTG
         BB24c7+/vWEh1N+B3tbOCTDQOiNcLpPaMNKN2psCxA3vw21Ro02zc/lRFfdG5ugsOLgK
         V8iTLnqh+F3OfvBmkUIV5tEMHn4ok0Ps1TuZRTlCKlSi0dLv+2A9gIdrj48yXRobzmiC
         1BrnBYWHkzpQjUG3EvB0+iA3Y+axiML1DG59614Zu9ErN6r9drJ4AuVpDzJO8MnhhHf9
         MCVg==
X-Gm-Message-State: AHQUAuYBjCK+zFsAtsAj6s06uO4+bpevC9CQRB5P3NANnxKGpvwOSEzJ
	H18zkaoJbeKWR3OgFw2uHBu5qs0RfgUGECxm8zTcDAjRRKf5F4ghF0R8q5Gl3ZijMxo/6hzvC7U
	RAzJ86AcEiPHFiEdqr7TBYgwBtwaQnNxNOF8hCh/oiVnNB+VGFaJ5J91L5bpqsQfIhw5aD7ckMU
	WEjt7LXFTWDQdiRw/kRW1JTdEtOgPCPMMHJQAYAvbLWSor5QPNCbLMcRnlsKIF/4ABlu3XxaSag
	XZLd/pdT9/AwodI+O8Dsdgy/bZ2ypHf4ULZhiOa0vPmzb7K/DtQNIlxpk5BNtwNwmwb78wGvKia
	jldXrmJEYQyQJzZIV8C4tQMRrgtvuwsX6HXp6NfVI1saxJ9p1pYcOqGZF6lXSs/1qL4YSkw84eA
	b
X-Received: by 2002:aa7:9152:: with SMTP id 18mr1891330pfi.215.1550761031649;
        Thu, 21 Feb 2019 06:57:11 -0800 (PST)
X-Received: by 2002:aa7:9152:: with SMTP id 18mr1891271pfi.215.1550761030781;
        Thu, 21 Feb 2019 06:57:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550761030; cv=none;
        d=google.com; s=arc-20160816;
        b=pIfYj4fD6+QTLSiII1puAMidH/Ep6HFhTB9FT2Fvh/4vlzLqn7zFfM5rh256u+XWlM
         gDddtfq9VmGmOYy8+3fPqgPV9guyUrd15JC3QgqyR4vwgs597KneWFUKi73/ebwijUs6
         +y/KwbPhq/5wAw3SDoBhVy3TKntnfvEnk1wKJGngpVEQBa2+KnVDqZrV+6ERkpM0+b0m
         WYof6Z8xhdybR/l/AkSoK50SwjZHDezPhGgaULRAyAarf5rqLX8l3WaiJqYW+tUYvwwH
         exUf+o5r0OcsJ3NzAoSNv8tGn9XJItN5iFXEdEAsfU5g/KNX4MLYr6U8gDfiJ4q+vkQG
         xNoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T6VBBJYyKGf9Yt7Yt1V87f/1+l66aJ7Oi3kjsALTg5U=;
        b=FTLqdfWIdNTyUcq9sKGSIg8DIncU/QFZo5fs3woMoT9Y/OgH28L1sZCMuDSI7Vt2jH
         hbWA3EBovvAO8QDMnpy+O3pCYp3swgszOt2Sy/Wvp+KnJ4SmxkCaEBWe3uPRhkQVFY38
         GRkmw+tICvp51qdurCu1QGVcha6FNBwZP9saqgAp7XST895Ql6DA47buSc7WoGv8PknY
         021RNccYzY/ZYv0RM++CWER1Ol9Prwa11GBbXD41A6UA+0p33yfZMWECwD/58TRv4mCO
         Zu8d0OSw1Pu2IBY8CyiUfJE0EorOf/jdongNDC7MrXVvQM0IhjUaNvcqRJX0XTft5mt5
         60IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wwPRWoH7;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q22sor34147962pll.36.2019.02.21.06.57.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 06:57:10 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wwPRWoH7;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=T6VBBJYyKGf9Yt7Yt1V87f/1+l66aJ7Oi3kjsALTg5U=;
        b=wwPRWoH7RscIRgKfRveK1NuIj23T/Lu9QLuQEw/AlQodiLk7Li6narB2OnDzzopxGh
         AIwxvNdAU3Dy8rZo6y55/MSqf91CVcBpEdUpQ/EdMhSETrfyce4iRd0DhiYWDR4Ogj9L
         52pXutYxgrmONKkaNVbCUN9nDGVt53Wnh10ONcI5kGw9RT1JNgIT7lUyRT3cPEXxyGpr
         fwxE93FUHAT4JpVECaIH8mY9FsDpLfbDacUHtRoRKGKVl89tqSIzfLKkbjIA1YKOtjPp
         S/am9lEOA3qmmUiZ8S3kpbmzDSGa7d2Atbak6PZMraWUy7dEFSny0KMOEmW9z5I66Kkk
         LYfQ==
X-Google-Smtp-Source: AHgI3Ib9Y14HOUHgb7hPC19Ds22hTsvdmOthEb6KPxlYMOxeEBURgY4/74WCmxUy5cW9dU9bAhaEZg==
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr20788392plb.197.1550761030340;
        Thu, 21 Feb 2019 06:57:10 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.43])
        by smtp.gmail.com with ESMTPSA id f10sm27599894pfn.11.2019.02.21.06.57.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 06:57:09 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 4C4EE301708; Thu, 21 Feb 2019 17:57:06 +0300 (+03)
Date: Thu, 21 Feb 2019 17:57:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 02:46:18PM +0000, Steven Price wrote:
> On 21/02/2019 14:28, Kirill A. Shutemov wrote:
> > On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
> >> From: James Morse <james.morse@arm.com>
> >>
> >> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> >> we may come across the exotic large mappings that come with large areas
> >> of contiguous memory (such as the kernel's linear map).
> >>
> >> For architectures that don't provide p?d_large() macros, provided a
> >> does nothing default.
> > 
> > Nak, sorry.
> > 
> > Power will get broken by the patch. It has pmd_large() inline function,
> > that will be overwritten by the define from this patch.
> > 
> > I believe it requires more ground work on arch side in general.
> > All architectures that has huge page support has to provide these helpers
> > (and matching defines) before you can use it in a generic code.
> 
> Sorry about that, I had compile tested on power, but obviously not the
> right config to actually see the breakage.

I don't think you'll catch it at compile-time. It would silently override
the helper with always-false.

> I'll do some grepping - hopefully this is just a case of exposing the
> functions/defines that already exist for those architectures.

I see the same type of breakage on s390 and sparc.

> Note that in terms of the new page walking code, these new defines are
> only used when walking a page table without a VMA (which isn't currently
> done), so architectures which don't use p?d_large currently will work
> fine with the generic versions. They only need to provide meaningful
> definitions when switching to use the walk-without-a-VMA functionality.

How other architectures would know that they need to provide the helpers
to get walk-without-a-VMA functionality? This looks very fragile to me.

-- 
 Kirill A. Shutemov

