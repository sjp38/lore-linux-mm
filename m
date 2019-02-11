Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA64FC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 828D52229F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="ftUZgy/F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 828D52229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F95C8E013A; Mon, 11 Feb 2019 14:09:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07FD08E0134; Mon, 11 Feb 2019 14:09:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B7A8E013A; Mon, 11 Feb 2019 14:09:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3FC8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:09:28 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id b186so75770wmc.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:09:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VpYmZSs9sbABUSNGoL/C0ayKwiKyD+m0wtsCebUKB6U=;
        b=b2XEXatTbiSFxkn44JyPXdEHeIR7EXShoDuY1szGUlaLLJQwd0IOVARraffaRgEExo
         C1UnRXaDv80JFilmiuJyHBFLqxXcHwLbFcalhZLMwj3VJ5/nVVtMMi68O/H4T9Kn9zf5
         bM4SQm1t7zyApQmNwKA53jbUaMtfYEq6jhELDaTTTdETgYjnuDCtt2owda2R57NSY7Qq
         jWRARcprwBtExvjIzWSqQEidvskAiJkqXOMZrTm6f+DfLH+HbKXBjekLsJ6yUqT4sxzx
         Wzb/1VgC1Su+WLSsTZ5CClB/mQU8XNSODa8sJE3xcyTgHzfUh1GP5B9GxRXjp8jr+ynQ
         Ni2w==
X-Gm-Message-State: AHQUAubIoP6vd+Yj5I7bgRl/sOdCd4OQ2PHFwMqfd+i1BUlFL5CFTB+B
	j8+BmxDiKU8V9cPb31UVYpEUY8SQWa17KPNQoMA3W7ZtC619TQx+NwO7UC+NARLw7lIIm70a0Tp
	ByGrPO5wUo+gbOlsjWkDNINYgSCOsVhJTe8t2iGxguCRD8UgZd615SqaX+jFshDqOXA==
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr27776491wru.291.1549912168043;
        Mon, 11 Feb 2019 11:09:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYgRELVtTuiLn7vj+k8nmTdV2CmlAdpLXgbSl2pCJ3HkhIFAmWXOoAa52dJuahkhooI+B1c
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr27776461wru.291.1549912167251;
        Mon, 11 Feb 2019 11:09:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912167; cv=none;
        d=google.com; s=arc-20160816;
        b=v+bBYWJK+WfHL/roUO+RtcnLzWpmzQ/vPfy5lFSz0fAehpLYRpofDeH4RqDH4OPeYa
         NRRwy5Gblw3+VpscOj090A9IuNTHkHDvQ1U9WSbZv6cazfkEfFnnVP3f6RQ7DYZtRglq
         Li3xsCyf09phWmFaDYHrQslfnJ0pGV3COd1qQlu//HI7w7OcYUYdqQ8rYiHKXhvMfmjG
         SkeKan+PsQFXA7dxVNa+pGx+TaQuQoqUMp5riGGbpfhzesPpLELLhBJegADMk7rwgFbJ
         f16WGVRcdqRJQdbqEMaDGJC82lYJEEhnAHAirHv6gD5M6WfPvnJ25rLGXqZpZncd/2Dh
         UWkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VpYmZSs9sbABUSNGoL/C0ayKwiKyD+m0wtsCebUKB6U=;
        b=X1blYSLxeOHsVvJ/ypgxWjk37onychL/i6y8knXQsHWwKanKSgXPRW403MUdT8e5M1
         TSGDxfpSaLpqneGXTUUn0lUaMMti0qnhwHhAH8+zxUb+Bov5IR+h1bnCwUbFYBH3XDDx
         alercb5VrPnRtzrHq+j0YIQ7H0MYpEPJ4fOaVF0sBHd50/mf6/I5C5hV4brCQjLoOlRr
         oSFJvEH1Vtw7fflPb7OHom/aLfcdTerOx3GsK7VuxbuAeKcrGUTaj1zO51VowSMazXnx
         zlomsvF4slWEwsPVl26eEb+6S798HUsLbnWyEWxLYaw6h0RFiDskV3LHPlSQgmMBxCWf
         SOcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="ftUZgy/F";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id h22si107976wmb.109.2019.02.11.11.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:09:27 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="ftUZgy/F";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 68D731EC01AF;
	Mon, 11 Feb 2019 20:09:26 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549912166;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=VpYmZSs9sbABUSNGoL/C0ayKwiKyD+m0wtsCebUKB6U=;
	b=ftUZgy/FPSTtySgYJ/UzFVeGCOsODAUsQKs6K7XANHrF+gDY4HvEaU0p6A1LhGKT6EUnng
	b4j2CPf+XzUIaOcE3tYhupgHOaZAiAnPwo8lm1rv4Oxwx4Extm8w3wUNJbLb18kXMeVTiC
	oIFMgrDwuw+4dp01dYzWJPpzr2HxZQE=
Date: Mon, 11 Feb 2019 20:09:25 +0100
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
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Message-ID: <20190211190925.GQ19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-14-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-14-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:34:15PM -0800, Rick Edgecombe wrote:
> This adds two new functions set_alias_default_noflush and

s/This adds/Add/

> set_alias_nv_noflush for setting the alias mapping for the page to its

Please end function names with parentheses, below too.

> default valid permissions and to an invalid state that cannot be cached in
> a TLB, respectively. These functions to not flush the TLB.

s/to/do/

Also, pls put that description as comments over the functions in the
code. Otherwise that "nv" as part of the name doesn't really explain
what it does.

Actually, you could just as well call the function

set_alias_invalid_noflush()

All the other words are written in full, no need to have "nv" there.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

