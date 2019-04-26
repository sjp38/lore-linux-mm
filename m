Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CBA8C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 19:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2975F2086A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 19:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Z0BFOsdy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2975F2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DA096B0003; Fri, 26 Apr 2019 15:22:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 863166B0005; Fri, 26 Apr 2019 15:22:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7293F6B0006; Fri, 26 Apr 2019 15:22:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 372466B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 15:22:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a8so2638767pgq.22
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:22:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=FF4FZYl2W8Jk8CR2ka+0dlxHQ668c1ySH4juVbxLjMk=;
        b=Y48EDOKnLUqCf+OwKmXzmNn+BMHlySjuCe5f5ds8nYa5TXFiIuFcPJz2Hnv7l65tRk
         ZQGhbR/6pz0/kdieCNDrFvarfCvatn+N+ph7YfTr7ZqChLcGvpM+rE5WyozSNkSqWEUy
         eBZkj4tIDSwxFqqLSEMh016d9DnBxb/IbTjWXUlXsJE5KvPO5eeeGNlthUvJIR4M3xm2
         Y9A9cmHr85/Ag9wynlUCaSnOPtOwxPo5Kj5Tnu4yqDsW9FIFYZ2vCq+bdiG4eCIvpxyw
         2KzXIxolzNsktvFfZAfP2t3R6yulRr1c7GH2aRfLpTKJAtuoRYO4YK3gmAetZCxZTyaU
         ynVg==
X-Gm-Message-State: APjAAAUfk1Of4lwblG28fHcSgeEVHHdtVF/O0PRu1GKS0iW/znS1xdpt
	8gWk6lTynCKprX/ZhQ977XVTqxzN2Ssybc3qTRJ9fauaauw3bl9Quw/ZuFwYjwOqB7IYio+LYiW
	DOF2RraOWbEfNmqUuq6pDlrnpX89w7VZB2L/Sv0LWI7QPp/zFEWycgbY6e56H8NmNPQ==
X-Received: by 2002:a63:ef53:: with SMTP id c19mr22230208pgk.120.1556306529227;
        Fri, 26 Apr 2019 12:22:09 -0700 (PDT)
X-Received: by 2002:a63:ef53:: with SMTP id c19mr22230053pgk.120.1556306526715;
        Fri, 26 Apr 2019 12:22:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556306526; cv=none;
        d=google.com; s=arc-20160816;
        b=xk+JT1Jy7hf6L1vRPXKSTurIpLhjtqomZteJSnUJ7lmVnYcEufBUMlIo8su49iqdYK
         cPSno8iSAa417oVSC1bMNHPVOYwIQ5E7c2TzmIaQby5NA9w8sZNhf/YfYjD+8jx22Hyr
         gSVTAjSJKcI47/XOSHPgCsXAYbGevVRRHnkreCWNd1JbByWw4m8awcChzq36Pjmiwhag
         qCNYgay+oPcVLJwKZjOV0dfDpLflZAwVUMjlr/LZ8HVosdYtK/fKvN6ddQ23lXqo/gog
         qYuniz1hpS4bRwCw0WDLI6gvgYt4LCq9VEny9lqMrMVkfpqMmTrfa9iGXKCwKouYc6iX
         DmxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=FF4FZYl2W8Jk8CR2ka+0dlxHQ668c1ySH4juVbxLjMk=;
        b=aWn0BYzbvs+u/34phvEbA1CWJtxHsbdR+7tD2mlyB1PUwXZq8WtEt5DcgBzcZS870g
         6ALlu3t2wf4RSf9Vn48Z57ERKB/JuJwFzHY5nfRWD2Z95tXwZYNiRlLvFPWnhEX/rOvZ
         NU+fYLBjzpC9GsjIjuyqm+bBJXLZqfioclfjqGK25Huzs13FWxeA7lYdakfBYoy1W3EQ
         3jL55Ac9cgOobOSMYncC+gbVCC1K8VK7e7HK4S2PW5puWUvPgd+CPBan/TzxeD3oNL5L
         oRgSXvf63tAxh//rtZIw10GkeEUSecrSwz31HZNsYFXFAQXDYwvZGegvYUgN1lNgNmDv
         AMTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Z0BFOsdy;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor1548907pga.44.2019.04.26.12.22.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 12:22:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Z0BFOsdy;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=FF4FZYl2W8Jk8CR2ka+0dlxHQ668c1ySH4juVbxLjMk=;
        b=Z0BFOsdyh3vzVdhq3uBu8jppABqHKQ5H1xwSxDYoIPvtClPPC4OY2Kv7zsmndh0lv3
         QZ0suuffaCBVkzz5TmVfeyE2mIO5h4dP6jurtPLm0zjL+ZB7E9jdrzPiMDnqwLX9CPjZ
         TnLdaYUCQ3l2WMmFISDbleRhVdmCC4+RRbJ143ZrSGm8cYcWmZGAaZvrN4BIzjVDDlnv
         MvhAm+52VMUyq5yDVUgbqM81BjAnqzyetFMCh4wF6E4BOaQL6gSD6x0GxAuvjo6+uEM+
         AeI+x6XvioX0LYmHeIwpSsDXtka2TdItjaN2uKnf+NQz93XNO/zJVILy8KGjaXmXwqzC
         vB8Q==
X-Google-Smtp-Source: APXvYqyN86L1XgDnKq2S+Y057Dpc5HJoiuuihnJ43FWtefeB9em09jfzBP8BQf0+Y25GyprdFJtWjA==
X-Received: by 2002:a63:fe0a:: with SMTP id p10mr44571075pgh.86.1556306524755;
        Fri, 26 Apr 2019 12:22:04 -0700 (PDT)
Received: from ?IPv6:2600:1010:b00d:521d:ec89:6436:4509:5564? ([2600:1010:b00d:521d:ec89:6436:4509:5564])
        by smtp.gmail.com with ESMTPSA id 71sm74497769pfs.36.2019.04.26.12.22.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 12:22:03 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16E227)
In-Reply-To: <1556304567.2833.62.camel@HansenPartnership.com>
Date: Fri, 26 Apr 2019 12:22:01 -0700
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
Content-Transfer-Encoding: quoted-printable
Message-Id: <BFDE56E4-6763-40C2-8E8A-661A22B4C0A7@amacapital.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com> <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com> <1556290658.2833.28.camel@HansenPartnership.com> <54090243-E4C7-4C66-8025-AFE0DF5DF337@amacapital.net> <1556291961.2833.42.camel@HansenPartnership.com> <8E695557-1CD2-431A-99CC-49A4E8247BAE@amacapital.net> <1556304567.2833.62.camel@HansenPartnership.com>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 26, 2019, at 11:49 AM, James Bottomley <James.Bottomley@hansenpartn=
ership.com> wrote:
>=20
> On Fri, 2019-04-26 at 10:40 -0700, Andy Lutomirski wrote:
>>> On Apr 26, 2019, at 8:19 AM, James Bottomley <James.Bottomley@hanse
>>> npartnership.com> wrote:
>>>=20
>>> On Fri, 2019-04-26 at 08:07 -0700, Andy Lutomirski wrote:
>>>>> On Apr 26, 2019, at 7:57 AM, James Bottomley
>>>>> <James.Bottomley@hansenpartnership.com> wrote:
>>>>>=20
>>>>>>> On Fri, 2019-04-26 at 07:46 -0700, Dave Hansen wrote:
>>>>>>> On 4/25/19 2:45 PM, Mike Rapoport wrote:
>>>>>>> After the isolated system call finishes, the mappings
>>>>>>> created during its execution are cleared.
>>>>>>=20
>>>>>> Yikes.  I guess that stops someone from calling write() a
>>>>>> bunch of times on every filesystem using every block device
>>>>>> driver and all the DM code to get a lot of code/data faulted
>>>>>> in.  But, it also means not even long-running processes will
>>>>>> ever have a chance of behaving anything close to normally.
>>>>>>=20
>>>>>> Is this something you think can be rectified or is there
>>>>>> something fundamental that would keep SCI page tables from
>>>>>> being cached across different invocations of the same
>>>>>> syscall?
>>>>>=20
>>>>> There is some work being done to look at pre-populating the
>>>>> isolated address space with the expected execution footprint of
>>>>> the system call, yes.  It lessens the ROP gadget protection
>>>>> slightly because you might find a gadget in the pre-populated
>>>>> code, but it solves a lot of the overhead problem.
>>>>=20
>>>> I=E2=80=99m not even remotely a ROP expert, but: what stops a ROP paylo=
ad
>>>> from using all the =E2=80=9Cfault-in=E2=80=9D gadgets that exist =E2=80=
=94 any function
>>>> that can return on an error without doing to much will fault in
>>>> the whole page containing the function.
>>>=20
>>> The address space pre-population is still per syscall, so you don't
>>> get access to the code footprint of a different syscall.  So the
>>> isolated address space is created anew for every system call, it's
>>> just pre-populated with that system call's expected footprint.
>>=20
>> That=E2=80=99s not what I mean. Suppose I want to use a ROP gadget in
>> vmalloc(), but vmalloc isn=E2=80=99t in the page tables. Then first push
>> vmalloc itself into the stack. As long as RDI contains a sufficiently
>> ridiculous value, it should just return without doing anything. And
>> it can return right back into the ROP gadget, which is now available.
>=20
> Yes, it's not perfect, but stack space for a smashing attack is at a
> premium and now you need two stack frames for every gadget you chain
> instead of one so we've halved your ability to chain gadgets.
>=20
>>>> To improve this, we would want some thing that would try to check
>>>> whether the caller is actually supposed to call the callee, which
>>>> is more or less the hard part of CFI.  So can=E2=80=99t we just do CFI
>>>> and call it a day?
>>>=20
>>> By CFI you mean control flow integrity?  In theory I believe so,
>>> yes, but in practice doesn't it require a lot of semantic object
>>> information which is easy to get from higher level languages like
>>> java but a bit more difficult for plain C.
>>=20
>> Yes. As I understand it, grsecurity instruments gcc to create some
>> kind of hash of all function signatures. Then any indirect call can
>> effectively verify that it=E2=80=99s calling a function of the right type=
.
>> And every return verified a cookie.
>>=20
>> On CET CPUs, RET gets checked directly, and I don=E2=80=99t see the benef=
it
>> of SCI.
>=20
> Presumably you know something I don't but I thought CET CPUs had been
> planned for release for ages, but not actually released yet?

I don=E2=80=99t know any secrets about this, but I don=E2=80=99t think it=E2=
=80=99s released. Last I checked, it didn=E2=80=99t even have a final public=
 spec.

>=20
>>>> On top of that, a robust, maintainable implementation of this
>>>> thing seems very complicated =E2=80=94 for example, what happens if
>>>> vfree() gets called?
>>>=20
>>> Address space Local vs global object tracking is another thing on
>>> our list.  What we'd probably do is verify the global object was
>>> allowed to be freed and then hand it off safely to the main kernel
>>> address space.
>>=20
>> This seems exceedingly complicated.
>=20
> It's a research project: we're exploring what's possible so we can
> choose the techniques that give the best security improvement for the
> additional overhead.
>=20

:)=

