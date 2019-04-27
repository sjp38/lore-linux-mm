Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B79FCC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B0F220651
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:22:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FHS55DQa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B0F220651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDC0E6B0003; Sat, 27 Apr 2019 06:22:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB2E46B0005; Sat, 27 Apr 2019 06:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA1D76B0006; Sat, 27 Apr 2019 06:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF866B0003
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 06:22:16 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id r21so5668473wmh.4
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 03:22:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=de/pNKGKEgMYXZXH86ILziX1rd53UXodWw8hsowIUv8=;
        b=WnbHaLHDOAymJ7eGH+2jFehBU+t6m7KOoEIvLJgzaa7D7FwEdLVJO5xfFv+81+9t1X
         KHMvuVEj/qZLwfZFD/hANydf2O0y511qyKs13vWIXPQrJ2uIsYLTwd8eteD/NBThPzmU
         4ow3MdPKy1+8k1m6EIn1yTSwK+AiwnmJzbFxvPc9hUyB74dO6MZ9LNbKD/1i4Efni932
         HMoukj/50fPxvVf0hrdnKnzcg9QmIESQDKx1Ju6R/lydmRrC/XOkKgjo+4vGhVwVrWi4
         IKd0bl5l7+whLh6qLWDmRIGbyzl8mdpsOmVzFgDZbzIBKV7RuZcQPAmZmvcNEEggipyR
         Qj0Q==
X-Gm-Message-State: APjAAAWxrTVgJBGPtZXFcnhNwbncxHTSuZWF75LQUfdyXC00rNZ/IzDQ
	1wISoJtvfe9bUhFxOkSV8KqQPPzw/02Zsvw6OOtDMnjFeoNtjN8z1hJI1joeSxFHqOXxRRpHeMj
	/o31e/diKLeGa/iDW8Qq/1Q2UDvDBki7C+5Dezw/R5Un2kak56l5q9pioMFSvIu0=
X-Received: by 2002:adf:db05:: with SMTP id s5mr3195213wri.247.1556360535770;
        Sat, 27 Apr 2019 03:22:15 -0700 (PDT)
X-Received: by 2002:adf:db05:: with SMTP id s5mr3195165wri.247.1556360534871;
        Sat, 27 Apr 2019 03:22:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556360534; cv=none;
        d=google.com; s=arc-20160816;
        b=uKzKq09Z07aX51ZV1VAjA6754FKGuvwQ+wO0S2/CqYXZ7nK3RGIl1WHblW3lhGG97f
         qy0z4IAyahEtF0Y5ncr/F5PG0XnSRR8y04YsCrdv3C/QQhiIEJwd5U/Xw+OBdJmzNfJv
         4S2m7lja7nTpDZOtTJTZbCPrSrDuJuWCvYY3P6enKISfFeemmiwrpn9RI5FxUwnxzNiq
         vaEMtbIY8/dbVVhuCtJvi8wSSQfiDDClqje6boVLzp1GnvGfLbugsmgy8CGtpEj7gNX8
         4RbM715XcEcNfmR3tYDZI2tGGxAVwD2uxbara6q9B3lQepOsw5VxYMPx5SH7XaQrsJVM
         F8Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=de/pNKGKEgMYXZXH86ILziX1rd53UXodWw8hsowIUv8=;
        b=Uckl4/nTo3G+TX8ymSbrFr6PRe5C/0fp519RKa6R28O08PCBIcnDJKdYFmxmySw034
         MfbACKwhZXwMjRqvriQNCGyRxESP13PBqWLeGrMgPTJotM1KQfiLR09E/b28GwkvEAeo
         l6iwIiH4ZWKzOGLSMhxcMqUa5pKKGTjrUMm8n48MjJhPk5VmRBhEZgcyA72eLo27U0fA
         kPmRW+m7wsAQ5jKZ+bP0e6BW9c6kxw7VwogAtTRK1s22vRXr4K3ycSx7zoeIyQfkvhVf
         F8BOhYWfwj29Aam8y9lcgEXJKe90LV35nTa7n7QfrjtoBwVqotIvEavSWLeuDLhjkrZq
         PdIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FHS55DQa;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17sor15589763wmg.15.2019.04.27.03.22.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Apr 2019 03:22:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FHS55DQa;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=de/pNKGKEgMYXZXH86ILziX1rd53UXodWw8hsowIUv8=;
        b=FHS55DQa7HVVSxloxBDHY12J9GGU3TjeKB6GK1roRSZM4TMRfM9dYUlqrluVFxih7k
         iqu3tTBkjTimmoUUtRc9/3kuRbifUQxHT8LeZx+3LiD5TMcOcCNzsKRhSkft2PMnPL90
         Vq7F63S3Kk/KiYW3nP3OGcmjIyvV1UhWBerCN544Ts7nwYpebY5UhaYNAcmZAxFT/J8R
         UKBu4UL+M9o669No1gk+IM/qFwaWfD17ifFjhxENuLAmPXM7CnsSd3smT++LnH3M3sJn
         Y4o3DE6SPT1Yxd9AwUXeqYCObbDwq5rB1DHi/FXl3JAY0c54wEc4nLvawZwVSQ5PJZ9e
         +/YQ==
X-Google-Smtp-Source: APXvYqz9DACRCDQQ8Go5wbjbYqQ8/ZE2Kbv27Orbu2KzfOAXTXxbqBkygu2CrWu329RFlIYxLpfm2Q==
X-Received: by 2002:a7b:cf2b:: with SMTP id m11mr10741651wmg.56.1556360534355;
        Sat, 27 Apr 2019 03:22:14 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id r16sm22477270wrx.37.2019.04.27.03.22.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 27 Apr 2019 03:22:13 -0700 (PDT)
Date: Sat, 27 Apr 2019 12:22:10 +0200
From: Ingo Molnar <mingo@kernel.org>
To: nadav.amit@gmail.com
Cc: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v6 00/24] x86: text_poke() fixes and executable lockdowns
Message-ID: <20190427102210.GA130188@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* nadav.amit@gmail.com <nadav.amit@gmail.com> wrote:

> From: Nadav Amit <namit@vmware.com>
> 
> *
> * This version fixes failed boots on 32-bit that were reported by 0day.
> * Patch 5 is added to initialize uprobes during fork initialization.
> * Patch 7 (which was 6 in the previous version) is updated - the code is
> * moved to common mm-init code with no further changes.
> *
> 
> This patchset improves several overlapping issues around stale TLB
> entries and W^X violations. It is combined from "x86/alternative:
> text_poke() enhancements v7" [1] and "Don't leave executable TLB entries
> to freed pages v2" [2] patchsets that were conflicting.

Which tree is this again? It doesn't apply to Linus's latest nor to -tip 
cleanly.

Thanks,

	Ingo

