Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4493EC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED4EB20679
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:02:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="LO2yBP/4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED4EB20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F1AB6B0006; Fri, 26 Apr 2019 14:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8789D6B0008; Fri, 26 Apr 2019 14:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A736B000A; Fri, 26 Apr 2019 14:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 371EC6B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:02:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m9so2540038pge.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:content-transfer-encoding:from
         :mime-version:date:message-id:subject:references:in-reply-to:to:cc;
        bh=uf9+Gc4IGjm5bXfQmbt+aGr/dzzLVRS2xZVZ9HE9m58=;
        b=T2zaTArpk1rtYsPhF+lwZNthjO/ULy4Q7BYU5uxt662b7OGEvkLsI54Z2dTEfU6lcI
         hZE8ySVquFHbU66GhbQ9jiVbSsU19lt8fl/4GayAzKR46bPRDEbQHCfb73PYblk4w3uT
         y72WMYwJIvoW68kZ7DLehBOe/HxE+MZxyUbE8yVUZBgpr7QFDZci1bVdJEeWAnzJzwUI
         n+m1TeqeOuVLMqQUPXZwutNkD8J48nzoSPvpgGSGbQDaMrfpqQJSgq+uszBn702aiqUN
         NZRr9+8/XxJr43fNG1mk6WhslbZ/tgVS+UWa8LPbybvcepFTfMCFqNhc5Fg1nIJZbVPT
         ajzA==
X-Gm-Message-State: APjAAAUbERbc9BJ546Klpu0ZUSxLSBSwxMPV1MGnDaRQa2kXfRWyxIZY
	LB6+g5xaZ/tmoW3UkmZ3Dhv7WBKMAiDQFWLmC/nolcXTeEfaO4oNPCYIgUyhVwEKffXoD6Vge45
	Hz5/PpQR+CtFcvKBAfspWt8C/JLAN7wG1C9/lzDFupoy3gRspCM8WNOX9eF+nowigtA==
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr45614267plb.278.1556301775826;
        Fri, 26 Apr 2019 11:02:55 -0700 (PDT)
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr45614184plb.278.1556301774899;
        Fri, 26 Apr 2019 11:02:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556301774; cv=none;
        d=google.com; s=arc-20160816;
        b=W/I/kS63m9VJSP2CO2BWROsU21ZAiko4194dnZlIq95/qJ9oFPTjS7AXsexR5vnsc3
         d0PHORyfwenWixvzHtCDnPgQcQLjanSV2mam0s72aXtzK0jFXfAhhkZhiKl6fBn0by9P
         BzoLT43hzsoDW4jonF3ktT/XuxMmK9jyXvNvwgna7keGj0YxZHkwRL3gitFX2X0/9TTc
         FZI7Iuu/zRRUaJaQFnn0ce2sDl7IHRGO5rU10tSOA4iNUpSuqNaOhOfyNxjA67fmCf+V
         5I/VNxpSICcGl3/zSAjapTq/wYmaDDl9x/zfApLeVv7gtn2+Q7YAaqvqeY3hBWucoEDb
         DTQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:in-reply-to:references:subject:message-id:date:mime-version
         :from:content-transfer-encoding:dkim-signature;
        bh=uf9+Gc4IGjm5bXfQmbt+aGr/dzzLVRS2xZVZ9HE9m58=;
        b=PrUhsCtAiuZgAdxSrnNFQBhhCPgLFRmGBzbc2CTQzS1dmhT4PTLgPjh6eA+9H3fXuU
         vBhlgCbdvpattMRgQX73FCJKI4XNM0s++7k5jDN/WebAFVzE5IWJyiT1eUXdM2Niagam
         X979mxf6a/oIo/4rxNjiLA4YyGpwsCEfwA1lbkYPimr4NvDCGsT0pWtRiOpmOE3yHDtS
         CFdQC+RdF5WctN5U4HmL77EZfS1TlBx7OJz5FOGieFxjRWKY92Nvs3ohxQoBby1U+zNB
         vJ8x8eWqDpp/ZtBG1qVuKKAF0k2rUSKBIlk0siNTpYL8zBAP5ZOuFbD0uqlzQePeDUHW
         6kWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="LO2yBP/4";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor29496737pfi.1.2019.04.26.11.02.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 11:02:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b="LO2yBP/4";
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=content-transfer-encoding:from:mime-version:date:message-id:subject
         :references:in-reply-to:to:cc;
        bh=uf9+Gc4IGjm5bXfQmbt+aGr/dzzLVRS2xZVZ9HE9m58=;
        b=LO2yBP/43Gaxq2G427F4quiP0FFiCIk+EbiXVQe5DTb0hxctE2AttHWb6tWuexLs3L
         ZkgG1bwlvK7lyTAodQcHTtnOIHnbCFp9kz0q5A0+btCGRUTPSe0ZDv/yUcUGoaI4Rnlk
         POZD7BlXQwFPt1fFpDSqeXtHETEWLhggiXmUS7fRcPEHbEKMnALPeB2xOwiFoJBB6XqV
         doRFYnnnMI40ZmQb8mE1Lgw+qjcbkk2g59wZvyeOR7s+5xpjLqhxr0BhfZT+vtLzmeT2
         pNJbsy6DDny9FxIJnnFyBwYu1AkprSd5oSgpU/8x9kx6LPOL9cmTqq+QBhTSJsDQVwa+
         NiJQ==
X-Google-Smtp-Source: APXvYqzBEXuTEM05o6uGn8vlD4CMCKRLEInJ6zCYpq9KPk9r3ASAk9h3Sp5XQ3azdexwEX66AO8sKw==
X-Received: by 2002:a62:e213:: with SMTP id a19mr46999249pfi.85.1556301774455;
        Fri, 26 Apr 2019 11:02:54 -0700 (PDT)
Received: from ?IPv6:2601:647:5803:15b9:2926:d41b:33e7:d8df? ([2601:647:5803:15b9:2926:d41b:33e7:d8df])
        by smtp.gmail.com with ESMTPSA id f8sm8533429pfk.88.2019.04.26.11.02.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 11:02:53 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Date: Fri, 26 Apr 2019 10:40:18 -0700
Message-Id: <8E695557-1CD2-431A-99CC-49A4E8247BAE@amacapital.net>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com> <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com> <1556290658.2833.28.camel@HansenPartnership.com> <54090243-E4C7-4C66-8025-AFE0DF5DF337@amacapital.net> <1556291961.2833.42.camel@HansenPartnership.com>
In-Reply-To: <1556291961.2833.42.camel@HansenPartnership.com>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
 Alexandre Chartre <alexandre.chartre@oracle.com>,
 Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
 Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
 Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org
X-Mailer: iPhone Mail (16E227)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 26, 2019, at 8:19 AM, James Bottomley <James.Bottomley@hansenpartne=
rship.com> wrote:
>=20
> On Fri, 2019-04-26 at 08:07 -0700, Andy Lutomirski wrote:
>>> On Apr 26, 2019, at 7:57 AM, James Bottomley <James.Bottomley@hanse
>>> npartnership.com> wrote:
>>>=20
>>>>> On Fri, 2019-04-26 at 07:46 -0700, Dave Hansen wrote:
>>>>> On 4/25/19 2:45 PM, Mike Rapoport wrote:
>>>>> After the isolated system call finishes, the mappings created
>>>>> during its execution are cleared.
>>>>=20
>>>> Yikes.  I guess that stops someone from calling write() a bunch
>>>> of times on every filesystem using every block device driver and
>>>> all the DM code to get a lot of code/data faulted in.  But, it
>>>> also means not even long-running processes will ever have a
>>>> chance of behaving anything close to normally.
>>>>=20
>>>> Is this something you think can be rectified or is there
>>>> something fundamental that would keep SCI page tables from being
>>>> cached across different invocations of the same syscall?
>>>=20
>>> There is some work being done to look at pre-populating the
>>> isolated address space with the expected execution footprint of the
>>> system call, yes.  It lessens the ROP gadget protection slightly
>>> because you might find a gadget in the pre-populated code, but it
>>> solves a lot of the overhead problem.
>>=20
>> I=E2=80=99m not even remotely a ROP expert, but: what stops a ROP payload=

>> from using all the =E2=80=9Cfault-in=E2=80=9D gadgets that exist =E2=80=94=
 any function that
>> can return on an error without doing to much will fault in the whole
>> page containing the function.
>=20
> The address space pre-population is still per syscall, so you don't get
> access to the code footprint of a different syscall.  So the isolated
> address space is created anew for every system call, it's just pre-
> populated with that system call's expected footprint.

That=E2=80=99s not what I mean. Suppose I want to use a ROP gadget in vmallo=
c(), but vmalloc isn=E2=80=99t in the page tables. Then first push vmalloc i=
tself into the stack. As long as RDI contains a sufficiently ridiculous valu=
e, it should just return without doing anything. And it can return right bac=
k into the ROP gadget, which is now available.

>=20
>> To improve this, we would want some thing that would try to check
>> whether the caller is actually supposed to call the callee, which is
>> more or less the hard part of CFI.  So can=E2=80=99t we just do CFI and c=
all
>> it a day?
>=20
> By CFI you mean control flow integrity?  In theory I believe so, yes,
> but in practice doesn't it require a lot of semantic object information
> which is easy to get from higher level languages like java but a bit
> more difficult for plain C.

Yes. As I understand it, grsecurity instruments gcc to create some kind of h=
ash of all function signatures. Then any indirect call can effectively verif=
y that it=E2=80=99s calling a function of the right type. And every return v=
erified a cookie.

On CET CPUs, RET gets checked directly, and I don=E2=80=99t see the benefit o=
f SCI.

>=20
>> On top of that, a robust, maintainable implementation of this thing
>> seems very complicated =E2=80=94 for example, what happens if vfree() get=
s
>> called?
>=20
> Address space Local vs global object tracking is another thing on our
> list.  What we'd probably do is verify the global object was allowed to
> be freed and then hand it off safely to the main kernel address space.
>=20
>=20

This seems exceedingly complicated.=

