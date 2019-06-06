Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A75C46460
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A3432083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:04:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="KdSuc6qU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A3432083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E895F6B02ED; Thu,  6 Jun 2019 18:04:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E38436B02EE; Thu,  6 Jun 2019 18:04:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDA676B02EF; Thu,  6 Jun 2019 18:04:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97FF76B02ED
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:04:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c3so27212plr.16
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:04:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=gywlfm9Yoih0bMD6ifzxFpYzXhaSqNtZ3Vx41KnjrlA=;
        b=UyFR6tMl9je2Prem+19Fy5pfvWE4Abv86nSM2A/vCwnzD63F2F8DfySen0mfp8t9x9
         WLZfbZf9lJGeJ+Hj0A1awWpZVP6uOPIXoIQE4EZ9ZytaF8WDPDM2bDOl/XPtkl6AQfRk
         0bNLoL4NAfcT6m5V8HeP7T6WJlYi2y6kv3mPWpXuTTPZUTk8ejDtM+JUB2x7AGj3ABRw
         Kc77Kw1J5AAVlXCt29ycsGhemd2VoQvswglfDLllbj55gqFtCKdQhkbITiTvetcnngh2
         xKOT2v4SDqtWs1TpvuMXaxTfeykX4OaFEnUfR1WMonNhruzyLo8t22u+/+AQTUdlRyd+
         e0HQ==
X-Gm-Message-State: APjAAAXwLYz1jo8PGdnu7rH0p0n413EvnziuGOpaC540564ZrRnv/IR5
	SGOKDzDvU5l/OJMIezUJzx+OLchfgu0pzHvGG09ZUYiyYhEkTJb2BpFiknoUBXr+/zvPWHXF9FP
	IgfbSb3/QDJKnWfznsLsO+YWzTzIUT6a+cnXBPR4GM8jrXcYYuWEsZPnWmGUvlOlJ3w==
X-Received: by 2002:a63:e018:: with SMTP id e24mr615435pgh.361.1559858686211;
        Thu, 06 Jun 2019 15:04:46 -0700 (PDT)
X-Received: by 2002:a63:e018:: with SMTP id e24mr615393pgh.361.1559858685459;
        Thu, 06 Jun 2019 15:04:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559858685; cv=none;
        d=google.com; s=arc-20160816;
        b=BszzyJq7p3pJL+xINAlPfqlOUFlkNLca+AVKzeCLu40bKyyIJfNhppyofY0pXsHHt4
         RjthAQqAKlmjQY0XDOSu3Xlm2Hm06nRWttCSi/nve51ATtFRkV/hDwPbFT5TZNspTmC0
         oWeA2gi7E9kwERQOx1AnKNL6cD06izodJUNh9i/qEp4ejtS5a5PRoCL+T/sbIjOH5Ap1
         WoWF4qnwLsTzltLMknDBSTpmSa/ZSS/Pa3WImeJB5GQF2ARjgv08DS0+KpDKTmUyNUl2
         MDP3E1Doqmka/VVdtUdnsFBD6TciN8KHIlYb+nyRIwlKlPLUpkxWTe68drFuCr4RKs2q
         LZgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=gywlfm9Yoih0bMD6ifzxFpYzXhaSqNtZ3Vx41KnjrlA=;
        b=uk2i+Y++E1dHva8LXNmJ4e8XpCbWAc+u6uFu5rUIqoYtsLiJcp7dQxuYw1Nn1VfFEw
         IP/XMExrMCm1cEeb19bjnLpWQyrz0DgZtL5lPjddrwN14gQw90eb1geobw/LgZTr3UKv
         NHY96y7MJSAgpCbTpQ241opyxwRG9fj6kG7rd+8G7T4PI94R+i3mqQHRtDpsWu5Z6+46
         MlQ/Tcrw6zpLRXvELfSfbYHn30eMuBNivD0ztie7Nhm4AZCZsXdcHa+TLv50ag2EpwcL
         jlniQc120TG9Gj1nTaFf1knexUviKYKe7DU1qhdyzLzavfy9cYRd3gV4mWziu1Aye+Q9
         AIoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=KdSuc6qU;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d63sor266070pfc.12.2019.06.06.15.04.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 15:04:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=KdSuc6qU;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=gywlfm9Yoih0bMD6ifzxFpYzXhaSqNtZ3Vx41KnjrlA=;
        b=KdSuc6qUwutVqZM2bBUwnBVByiqJN/DKQJSosVOKivdyswe1dj1OAQfWDjDK5YJqE1
         3t/oHHgHgs+xW+fdWxVOLNWJCnOHYy0LQGMB6JmAUG7IXoYQOym9OJyHHhJSkOCWAnhx
         8ZyvTJDobg2BeY5W4nGvYAgDyNSaNV7cPjuqETuPpAL/hFFP94VqLDOOhRHizSEdYNbX
         rKoG4vr6XTyxTWKCztg7TkQKMD0hCuWqA7q9AZ+TyVE1Pp1fsVn2MY93Iie5UNcgJ7RK
         cwWcCP2/TdvUQakRROAWM6UmzRJhH+2vJHzQ8AEnKylWm8x9WUlTp6jAtdEEDQmMH5ut
         jTeA==
X-Google-Smtp-Source: APXvYqyk9QmRHSJ+vGdphw2yaxfTPiy05mkf3a1uNeH7r3/M6ySs3Tt2nDTXY7uEDRPl7vLLEP5vrg==
X-Received: by 2002:a62:1456:: with SMTP id 83mr3919945pfu.228.1559858685103;
        Thu, 06 Jun 2019 15:04:45 -0700 (PDT)
Received: from ?IPv6:2600:1010:b02c:95e1:658b:ab88:7a44:1879? ([2600:1010:b02c:95e1:658b:ab88:7a44:1879])
        by smtp.gmail.com with ESMTPSA id s12sm68142pjp.10.2019.06.06.15.04.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 15:04:44 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 04/27] x86/fpu/xstate: Introduce XSAVES system states
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <0a2f8b9b-b96b-06c8-bae0-b78b2ca3b727@intel.com>
Date: Thu, 6 Jun 2019 15:04:41 -0700
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <5EE146A8-6C8C-4C5D-B7C0-AB8AD1012F1E@amacapital.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com> <20190606200646.3951-5-yu-cheng.yu@intel.com> <0a2f8b9b-b96b-06c8-bae0-b78b2ca3b727@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On Jun 6, 2019, at 2:18 PM, Dave Hansen <dave.hansen@intel.com> wrote:

>> +/*
>> + * Helpers for changing XSAVES system states.
>> + */
>> +static inline void modify_fpu_regs_begin(void)
>> +{
>> +    fpregs_lock();
>> +    if (test_thread_flag(TIF_NEED_FPU_LOAD))
>> +        __fpregs_load_activate();
>> +}
>> +
>> +static inline void modify_fpu_regs_end(void)
>> +{
>> +    fpregs_unlock();
>> +}
>=20
> These are massively under-commented and under-changelogged.  This looks
> like it's intended to ensure that we have supervisor FPU state for this
> task loaded before we go and run the MSRs that might be modifying it.
>=20
> But, that seems broken.  If we have supervisor state, we can't always
> defer the load until return to userspace, so we'll never?? have
> TIF_NEED_FPU_LOAD.  That would certainly be true for cet_kernel_state.

Ugh. I was sort of imagining that we would treat supervisor state completely=
 separately from user state.  But can you maybe give examples of exactly wha=
t you mean?

>=20
> It seems like we actually need three classes of XSAVE states:
> 1. User state

This is FPU, XMM, etc, right?

> 2. Supervisor state that affects user mode

User CET?


> 3. Supervisor state that affects kernel mode

Like supervisor CET?  If we start doing supervisor shadow stack, the context=
 switches will be real fun.  We may need to handle this in asm.

Where does PKRU fit in?  Maybe we can treat it as #3?

=E2=80=94Andy

