Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91712C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E512083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:48:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="do9XptRb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E512083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBA3E8E0003; Fri,  1 Mar 2019 16:48:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6AA98E0001; Fri,  1 Mar 2019 16:48:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D80918E0003; Fri,  1 Mar 2019 16:48:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97A2F8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:48:57 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id f18so18403711pfd.1
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:48:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vMUpOerzimh7H/ZPQ+1fel3zw8mp4Atm+/r0u+Z/foA=;
        b=e/us+NC0yNhRNi702ZSLtVHRhmO/Q9xUkWB5Ly2c0d4k8dGTT8BAsGKuUf1rdaiIrU
         JpjyhgvmSt00TJOTirszdp2Q1YxnPRrFTFCQRWVF/zlJnJv1MntS8WmFmn7zcPKf4L79
         Ne8HhC9hqxo44FN7CjUTtfadXJQHZMuO1xgEbz82RVF8ZBqkKvykL/3Vq9g1vs3mSrJV
         aO/xQNFIwtfbjHpj0NoaI/9Nncwh2PUll7305f0N7uYmnIKhH6d8qCteFUjOlOKvfpYW
         cLGXWlVZbZ5S0pDX8cjMH8wKvm19ERpXnDTkIIbr2eQyqI5pl/VJtEcVgvG4AcXLQeA1
         2hLA==
X-Gm-Message-State: APjAAAXDGaIrotwGyVi+7tIPPtu2J22dIGKDbLvWobZGKDTk4hFnU+O3
	PGj0CE3xAmpagCyGznSvXUCv7r0qB9SsKdUSTRgJgo0TaaJ6K+KQOQGgrUoT8qz2q8IwLyFhh/P
	wN2lyg4CApXBqWNS7E9/2sR2inPQLEf74A1+tCB+dntNIszK1NQONuXaBeyWFcq1bh/nwwDuYzE
	3g1LLkMrCukm12Oe3r+ceaGuzlNZNHNqxC2a+tIfwfrhgSnTZm6/W68NLKysXFPdSQ5dV7ug5qh
	lAgAIAU/+a1iRbvKo952L42uVsWr1nMo6TcrLtGb3g90bqRezlkzdnaDizbA0bAbx9V+R64aWnb
	ilmlf34OtgSJaxS7TT1o0WKD71ZKI5xCzPcAwEozVgEeddnZJFH+U6ZMeqFnS+KxCQRZtS4diGB
	a
X-Received: by 2002:a63:c204:: with SMTP id b4mr6902910pgd.335.1551476937307;
        Fri, 01 Mar 2019 13:48:57 -0800 (PST)
X-Received: by 2002:a63:c204:: with SMTP id b4mr6902866pgd.335.1551476936515;
        Fri, 01 Mar 2019 13:48:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551476936; cv=none;
        d=google.com; s=arc-20160816;
        b=cQDousip4maILkfHjuiKblzVP+pBmz1cZq0GLbSMf0VRd1xoIog2ko1ijR5xZWP60n
         1EU4om8antkZkDu7XNxswB8A0ODDKFZFO+aPApwCKPzPFyg/5HvzlCfIvlZsLCFyNGO0
         B3A+KYVxyRumdrM3Q/193DvSjIwM5PD+ZV1ttUEbhbgOb3LgZmJ1GLDA/JfOgGG8kcqK
         1/MfZN4zl+UVwajeP8QZbrPHB4R9z8Dg90ICctgR9b5pKXkln5a2Bd7KEGlRn48yqFfg
         UW1Lu0WD5OqXcs1QhyfDho418MCKcR/7hQj9QLa5DC2Nk4KDnSQeHUlcLgSCjXnU/Rz2
         qPUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vMUpOerzimh7H/ZPQ+1fel3zw8mp4Atm+/r0u+Z/foA=;
        b=xax/K+iNaUxpCrlRd407bIj4zDHcd8X2WXnZI5SogQ5u7ID2dx9Ttn9ZhNlMv0PNLD
         ZlMdOWOLW2sntgJvEkuXvgj42qkZQ4HigTz/chZsaTh9ciQVMgKH2E6rw9gKW1YCyYD8
         lKQg7CcrIPHebpRHZBXB/jm7uoMnniJQzBrVOml8ohgPEP7Sxez3ji3sP/0KQIC7F4vQ
         eCcTXBV/dwi0F/hqpcJ8KWjXPe+nznwdQZN34KUmE3LlCd468RAH12X150t8R0/9g/jN
         n6QWO2Gi7qXCqu4dkV3fpj+86V1TL1GLUXZZCXw5m5jCGo+wqhyUjZzuELq7TnOvI/Cy
         2IMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=do9XptRb;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id be3sor34493920plb.25.2019.03.01.13.48.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 13:48:56 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=do9XptRb;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vMUpOerzimh7H/ZPQ+1fel3zw8mp4Atm+/r0u+Z/foA=;
        b=do9XptRbUwmwOJ3TNHNpY7KbSRtzGbGiAA33/7Hv1NxUsNU78SH63CuZevLDRyJ/L8
         knvcsZg82jPJQe8lRj8nhiuBnN3x//VBi/vZqNhmINjvFG434tEWr3skViQU3GOMnXOE
         icjaf/5gZwATMlgbtZt42vLGlXZ7XwyOWGzO2EMcmVkvSkbK8C0fFf+BQC6NHlpfyHnV
         M8uXTnLkroLn0Tg4TvhqHc3lXzfbVckhBiLRjNCnTBOCYqr803EfjmoxG/telV7wwSzz
         8+lnnSz3pyJB2cuyYR1oHmgV/URTcruOp8IrEWqtU5CpoBeyNR+WW3ylkA9wPl7Xk7mo
         lYog==
X-Google-Smtp-Source: APXvYqzPzAwmBTBYphssJHL3LTRyrhCSKJni1K7CY95rVxxRffbrHWIoSLpljCZS1fuiXLzqGmQj6g==
X-Received: by 2002:a17:902:7e46:: with SMTP id a6mr7768122pln.150.1551476936266;
        Fri, 01 Mar 2019 13:48:56 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.43])
        by smtp.gmail.com with ESMTPSA id l72sm28226444pge.39.2019.03.01.13.48.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:48:55 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id F3EE43007CA; Sat,  2 Mar 2019 00:48:51 +0300 (+03)
Date: Sat, 2 Mar 2019 00:48:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Mark Salter <msalter@redhat.com>,
	Aurelien Jacquiot <jacquiot.aurelien@gmail.com>,
	linux-c6x-dev@linux-c6x.org
Subject: Re: [PATCH v3 05/34] c6x: mm: Add p?d_large() definitions
Message-ID: <20190301214851.ucems2icwt64iabx@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-6-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227170608.27963-6-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 05:05:39PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For c6x there's no MMU so there's never a large page, so just add stubs.

Other option would be to provide the stubs via generic headers form !MMU.

-- 
 Kirill A. Shutemov

