Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91BF3C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D0D92186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jxBVSrqh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D0D92186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D841B8E00DC; Wed,  6 Feb 2019 12:33:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE4608E00D9; Wed,  6 Feb 2019 12:33:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC1048E00DC; Wed,  6 Feb 2019 12:33:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 625F78E00D9
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:33:41 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o62so1348786pga.16
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:33:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=rYbgX2FNZSLFQiDq0Ih+9oGqomi8Dxzpd7WK0+FcTcQ=;
        b=ZIaWcr7iRpMT1nWDeLDch/C2WunYjvmtNfiHIlrsGGCr9zoqyKopJMsULBWBzBRfpL
         LWbvHkLbm6OJ7dksseo2b4dXXt5RpC9U+A6OmMxtSAb4UZaacokjFvichktLKeToQpHW
         nSqn4QwkzNy59YvPt+K1e5c/cgROt6/WSRi2OM0qVdb+YzdKyc1Ip4HxhdbunjvSmm4B
         Aa31QxuYaIODzo8FDH3A0Fve0esar4e/z3m+2xzYno1C8fTW1QuVd+kamK+l60KmUXcP
         h2yo2x4v447qKMLfXu6lQ85Tx5cDgciJwoUW8CF9cI777BEBsR/ijPNhHLMwCmxC18oH
         ertg==
X-Gm-Message-State: AHQUAub67+Y9RbS+DUT0W+4boAaZbHm/EeR47QJ2o7JXClD78Dn10DzL
	wGDZehxaqPkGR2BVwLYwv62Hgn7C392ON7Phnxf64Y1GnQg3ZkbWvGAjtNBwQqUD8RTmQ4L7EOz
	paTJnSLuG+j9GkXgzYoHiPi8bFPxDxHv/aItEopYlYeC9T+USIqtqrwLGtVtXRTw9DBgdOtuzhl
	tR9LvnitJIDCRjfiP8yygxkxHb281MSegW+PDFPqu9mgygAHSpfjvEeaHPEXvzl9WISbW917lDo
	AfRlZDDlU6dAUC29enIZTuqLKoWf96VVVroJFNWWgfaHEJFlyT5TIfWQYHWXN6RyBVGUKigAw7s
	5Zf0OIq7hit6ZTXC8l5Jxkpl2ExvITAH8Sff1RBQJCxLPymr7OQNmK+XA3SccR9eEm9WNN5Fhbp
	M
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr11473084pla.47.1549474421059;
        Wed, 06 Feb 2019 09:33:41 -0800 (PST)
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr11473019pla.47.1549474420335;
        Wed, 06 Feb 2019 09:33:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549474420; cv=none;
        d=google.com; s=arc-20160816;
        b=TjlAs8y88Ywj6akxS6LgpHcv/VAdwrzfi3wVoCZx3vcO9AUP07j8Q6givd5GrA1u80
         BrLr6spms5I7oeBIbH1VG+Vg6HbN7ClO3711fdh2Q8kRjzHd39txZ7ETbnOjImyN/zkw
         l+WFCYfH+RydMRRt9w7R2rBQgwc6M+PGmUib0GK8mcKHbWOp5iexctOnreAOjIoI8/Sf
         D1+QQkcgfENEmo+gG8QuD5hPrjDhn8SwRCeMoJon0kYH9dsvVqc469J/k5Z/NjQwQSaM
         1aaDKnkBX/lBSTNlagtasqd/g/s2EaZOLgF5wXb3Mk2kLmcrLl/KaF2ALlJz3PUqOefJ
         2Fkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=rYbgX2FNZSLFQiDq0Ih+9oGqomi8Dxzpd7WK0+FcTcQ=;
        b=wTj7w7UEoS8KoL0nVbhmxADXzvAICq0kdYscQ/qjhHdtzelvvC6yM4n1BC9tqEpUen
         PTUag33jQeiwmxJtGbVrGCqjUso2lSUUkVrEIx/A0YISZybVc498CXOxdTh2vFnnKXvg
         uzq/OIumQh8TKiqfZzxfdil+xGl+/TQQWsQoE3O5GMFBdEDgJc2YMNXk3QGDNq8efWl1
         mSt4S+wd30JOr1+El+/lbDoauVODKWQxduXG6M7nqAQhSN3bvfMYiUB/EMy2UIR+KfWo
         fEtvhL2CTROF9piONvK4R6Qo99e9Kp5T4glrHRrnCqk1G3AMmFmTYuIYIX8ZGXHxRKQN
         lw9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jxBVSrqh;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k196sor9969442pga.61.2019.02.06.09.33.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 09:33:40 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jxBVSrqh;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=rYbgX2FNZSLFQiDq0Ih+9oGqomi8Dxzpd7WK0+FcTcQ=;
        b=jxBVSrqhK2+6jA9mgt1ZG2E6Yi97wIPX6W+CP4vKddME0zOC5E6Nq1muZXBqDq66Ye
         VVAsjSUD9dScTXpLAZBgRw1MBsrpIoTC5JQhT21UolL971aHLI6k3RCW7jONQsJbBlzP
         t9jtC1tCPW113d7khRQ4pUr9iK6z6+Jl2znriGGF6Tc3h8tJm7WgEkq29wzTlX5g7Mg9
         7qQk6+j5bVvHFcSvP+fLT9HshRbtp0RQyolyO61o12w+C/C+MMWVvqfybCZv/UsMV/AI
         BKEhQZUPTuOaO1k+dtte1NfawOt3RDQ2LvtZ9jMask9lAZN5wdlfaI5HXjrthV8o5cSn
         2XNA==
X-Google-Smtp-Source: AHgI3IZO/nBxjBj7hWYe6SBT7x8lwLWKo0SvM/vK6C31+42XzDoMO/FAAmIlRnhVDYWo38sCKnYxiQ==
X-Received: by 2002:a65:62da:: with SMTP id m26mr10648561pgv.278.1549474419293;
        Wed, 06 Feb 2019 09:33:39 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id a13sm436912pgw.34.2019.02.06.09.33.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:33:38 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 08/17] x86/ftrace: set trampoline pages as executable
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190206112213.2ec9dd5c@gandalf.local.home>
Date: Wed, 6 Feb 2019 09:33:35 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 deneen.t.dock@intel.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <5DFA1E3C-A335-4C4B-A86F-904A6CF6D871@gmail.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-9-rick.p.edgecombe@intel.com>
 <20190206112213.2ec9dd5c@gandalf.local.home>
To: Steven Rostedt <rostedt@goodmis.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 6, 2019, at 8:22 AM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> On Wed, 16 Jan 2019 16:32:50 -0800
> Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
>=20
>> From: Nadav Amit <namit@vmware.com>
>>=20
>> Since alloc_module() will not set the pages as executable soon, we =
need
>> to do so for ftrace trampoline pages after they are allocated.
>>=20
>> For the time being, we do not change ftrace to use the text_poke()
>> interface. As a result, ftrace breaks still breaks W^X.
>>=20
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
>> ---
>> arch/x86/kernel/ftrace.c | 9 +++++++++
>> 1 file changed, 9 insertions(+)
>>=20
>> diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
>> index 8257a59704ae..eb4a1937e72c 100644
>> --- a/arch/x86/kernel/ftrace.c
>> +++ b/arch/x86/kernel/ftrace.c
>> @@ -742,6 +742,7 @@ create_trampoline(struct ftrace_ops *ops, =
unsigned int *tramp_size)
>> 	unsigned long end_offset;
>> 	unsigned long op_offset;
>> 	unsigned long offset;
>> +	unsigned long npages;
>> 	unsigned long size;
>> 	unsigned long retq;
>> 	unsigned long *ptr;
>> @@ -774,6 +775,7 @@ create_trampoline(struct ftrace_ops *ops, =
unsigned int *tramp_size)
>> 		return 0;
>>=20
>> 	*tramp_size =3D size + RET_SIZE + sizeof(void *);
>> +	npages =3D DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
>>=20
>> 	/* Copy ftrace_caller onto the trampoline memory */
>> 	ret =3D probe_kernel_read(trampoline, (void *)start_offset, =
size);
>> @@ -818,6 +820,13 @@ create_trampoline(struct ftrace_ops *ops, =
unsigned int *tramp_size)
>> 	/* ALLOC_TRAMP flags lets us know we created it */
>> 	ops->flags |=3D FTRACE_OPS_FL_ALLOC_TRAMP;
>>=20
>> +	/*
>> +	 * Module allocation needs to be completed by making the page
>> +	 * executable. The page is still writable, which is a security =
hazard,
>> +	 * but anyhow ftrace breaks W^X completely.
>> +	 */
>=20
> Perhaps we should set the page to non writable after the page is
> updated? And set it to writable only when we need to update it.

You remember that I sent you a patch that changed all these writes into
text_poke() and you said that I should defer it until this series is =
merged?

> As for this patch:
>=20
> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

Thanks!

