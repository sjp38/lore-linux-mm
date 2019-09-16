Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6FDDC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:53:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DDA220650
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:53:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gjY6ySzf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DDA220650
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 344806B000C; Mon, 16 Sep 2019 10:53:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31B106B000D; Mon, 16 Sep 2019 10:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230896B0010; Mon, 16 Sep 2019 10:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 02A766B000C
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:53:09 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B14112C2A
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:53:09 +0000 (UTC)
X-FDA: 75941076498.19.smash45_55c013d653a37
X-HE-Tag: smash45_55c013d653a37
X-Filterd-Recvd-Size: 4804
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:53:09 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id o18so8016833wrv.13
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:53:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BIxRZcPCxemm3w3c90iYG9SEIp3wWGWvFQcOwYAS7KI=;
        b=gjY6ySzfqUiv73erAouVCG8ExSbabj3HV0tIGoWswYpz5Ksu+334Xzkl96/6Ut6qdQ
         B4VtxrluXHNvE54lYsFHddGKGDOtZg/0JTMpgnyuk8Z4dEkQGgAMos1GRskpiQRAiB0f
         PRRPfpc5yjej/b5NsCJd1ji7o6678tGO0bdn5+B8gvlv6Pfedx+wLGlZwjgk3g+3UIRE
         jKYoFi9U2B0y3MSsgTJrqJOdW/BmEj4Y+d5uz7rQPlK9zwKjYWfOBcN8y9PPBJ++yLHe
         MRrJ2fldtFr7c1BIVOEIhmciM4vWOtCCqymoRBqUaJL51sQZR+DEhKzVUeB8t+ZG4e+n
         YrUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=BIxRZcPCxemm3w3c90iYG9SEIp3wWGWvFQcOwYAS7KI=;
        b=LkRkNcNz9v5sHKkuh4UENnvJqKUpYguL9+usQZQ56ANFrjOecqGD1iu7co6dKPwhrh
         HTqx6tEHb55zhe9CCR5OQWQVkWbRnrhhO1TSxPotmC15Eo6vNfzF9/yfBSOC83kZYspr
         Omljobjf+4Kai+1KOihNS3FlyMn1k0kojVT3thYh3xAF2WD0vRJUJpDSvv/hEM07dERH
         rfCcZxrLBi0WC7bSGivWdbx48Qsf8mTnEHkpspQvt+Z89nPY+A+i4LBJ5NJ/O7vb0D+r
         R4iH5LgzZ5fy+EIU17x05Ljpx0peH9S03Wfcsk4SKBB7VUDRK6CJSCGDo+25DT6i21UE
         u+Hw==
X-Gm-Message-State: APjAAAXU5E1MswQbBKKmzmxou2MCCYZXPGRHAT4Tg+3Q07F+zkFsSGi1
	F5fdkEliaiylrr3Z/uR28KQ=
X-Google-Smtp-Source: APXvYqxNRU6rzmKIm5asYmfPhm1QaZnSQXAejuft7hw7TIBzZ+GWUKy4q92ALQ0MtEuqxJtZK8uXlQ==
X-Received: by 2002:a5d:4491:: with SMTP id j17mr114245wrq.257.1568645587990;
        Mon, 16 Sep 2019 07:53:07 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id t6sm104711wmf.8.2019.09.16.07.53.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:53:07 -0700 (PDT)
Date: Mon, 16 Sep 2019 16:53:05 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] x86/mm: Enable 5-level paging support by default
Message-ID: <20190916145305.GA30629@gmail.com>
References: <20190913095452.40592-1-kirill.shutemov@linux.intel.com>
 <8435951c-d88a-a5c6-5328-90c9f2521664@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8435951c-d88a-a5c6-5328-90c9f2521664@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Dave Hansen <dave.hansen@intel.com> wrote:

> On 9/13/19 2:54 AM, Kirill A. Shutemov wrote:
> > The next major release of distributions expected to have
> > CONFIG_X86_5LEVEL=y.
> 
> It's probably worth noting that this exposes to two kinds of possible
> performance issues:
> 
> First is the overhead of having the 5-level code on 4-level hardware.
> We haven't seen any regressions there in quite a while.  Kirill talked
> about this in the changelog.
> 
> Second is the overhead of having 5-level paging active on 5-level
> hardware versus using 4-level paging on hardware *capable* of 5-level.
> That is, of course, much harder to measure since 5-level hardware is not
> publicly available.  But, we've tested this quite a bit and we're pretty
> confident that it will not cause regressions, especially on systems
> where apps don't opt in to the larger address space.
> 
> I do think endeavoring to have mainline's defaults match the most common
> distro configs is a good idea, and now is as good of a time as any.
> 
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

Ok - in terms of timing it's obviously *way* too late for v5.4, so I've 
queued it up for the v5.5 merge window in tip:x86/mm. This should give it 
2-3 months of additional testing to shake out any weird interactions and 
quirks.

Thanks,

	Ingo

