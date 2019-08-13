Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10142C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE02F20665
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:49:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Wt6ztQ2X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE02F20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66AAC6B000D; Tue, 13 Aug 2019 19:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 619916B000E; Tue, 13 Aug 2019 19:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5089B6B0010; Tue, 13 Aug 2019 19:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 2923C6B000D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:49:33 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CA0AF180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:49:32 +0000 (UTC)
X-FDA: 75819048984.29.tree84_19189f3c7b048
X-HE-Tag: tree84_19189f3c7b048
X-Filterd-Recvd-Size: 5053
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:49:32 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id bj8so2907690plb.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:49:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=yL2GiSxONyR1+wf+cPEJ785qgYB8kzY/mss0H7pGC9M=;
        b=Wt6ztQ2X+fWJO0FTPgcX9A+51Mq8+dTZ9Ad+A3iCM8ClCkHgqKWJ2Drcvb3RRKr7tY
         erf0TC5YpqS2Portj7ZVBheih5czwyWoynvvG+OcmmO4kYKcTGfe2f3XrwTEAsq4mi21
         F50sQEzYTRfQKIDH+vxbJVarJg8gOG8ti6o2Fc+g1ZQKwAv93sQYllOrj4oWJ0zUPD+X
         OhZHWL3rBvb7RYeJg5DrjtfulYBGFzk0abwLsjlwIA2YbLnzPETAHKm0OIYnmu8wnuCN
         S6zZGySHxEitvDXRzvENqoZpHDohSYEySTt2GO05uL68b4/lXRsTldj/46PsM5r7KGQH
         nhyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=yL2GiSxONyR1+wf+cPEJ785qgYB8kzY/mss0H7pGC9M=;
        b=Ka2oActh7uKX1hnviOCdwvfMMReb/am+5lkCSllHDf79BspqfHKv5RFBfanfPqF2X3
         GiT3ZLDXNj8jGvO0J5vlrS8S8BcUY8LQ4EW9yE+AUwBH1EshPGFOb2aebMfvheGi3hgm
         4cJiLm26TUkxB+2pnKr1sG/BUJepbxRX+InSSPkmmp9eNqKi3QUbxGWnQ/cmQ3HRNPgq
         wTQFZeO2aWiOsX5VQJdmH0gATLj5tCdnVdODF3NzmT0GvjioUUnwZAoRsLBEgNevME93
         c/9eDGbRpcRlAmcVjAqtVM23Cd1cVmn7QnFIvONn/3lpJpRuUvCRrVfx2g41jx4fZDQt
         2FTg==
X-Gm-Message-State: APjAAAXjf8Gtl4njb21HDLAxvQ4esGoS07dCokXZ8FxT9GN8s76CGe+g
	TVU2Y//vbZbYVXTO5eLqrsgBqw==
X-Google-Smtp-Source: APXvYqziYoxNMLaC/s1uQ9IVzw788DhInlAx7eBm4/seDB4Szhev8YYMyLyUEb33esQFu71+edIwvw==
X-Received: by 2002:a17:902:2ac7:: with SMTP id j65mr40372077plb.242.1565740171253;
        Tue, 13 Aug 2019 16:49:31 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:6cf1:fbba:cb42:db60? ([2601:646:c200:1ef2:6cf1:fbba:cb42:db60])
        by smtp.gmail.com with ESMTPSA id bt18sm3110564pjb.1.2019.08.13.16.49.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 16:49:30 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v8 11/27] x86/mm: Introduce _PAGE_DIRTY_SW
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16G77)
In-Reply-To: <dac2d62b-9045-4767-87dd-eac12e7abafd@intel.com>
Date: Tue, 13 Aug 2019 16:49:29 -0700
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
Message-Id: <08A983E6-7B9C-4BDF-887A-F57734FADC9E@amacapital.net>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com> <20190813205225.12032-12-yu-cheng.yu@intel.com> <dac2d62b-9045-4767-87dd-eac12e7abafd@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Aug 13, 2019, at 4:02 PM, Dave Hansen <dave.hansen@intel.com> wrote:

>>=20
>> static inline pte_t pte_mkwrite(pte_t pte)
>> {
>> +    pte =3D pte_move_flags(pte, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
>>    return pte_set_flags(pte, _PAGE_RW);
>> }
>=20
> It also isn't clear to me why this *must* move bits here.  Its doubly
> unclear why you would need to do this on systems when shadow stacks are
> compiled in but disabled.

Why is it conditional at all?  ISTM, in x86, RO+dirty has been effectively r=
epurposed. To avoid having extra things that can conditionally break, I thin=
k this code should be unconditional.=20

That being said, I=E2=80=99m not at all sure that pte_mkwrite on a shadow st=
ack page makes any sense.

> <snip>
>=20
> Same comments for pmds and puds.

Wasn=E2=80=99t Kirill working on a rework if the whole page table system to j=
ust have integer page table levels?=

