Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DFCDC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A7C7208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:40:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="xrvdgiwg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A7C7208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A676D6B026E; Fri,  7 Jun 2019 16:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A17106B026F; Fri,  7 Jun 2019 16:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B9726B0270; Fri,  7 Jun 2019 16:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB606B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:40:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so2164229pgs.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:40:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=/zXZ0PAO7hrTuftMmJADCccAFJNVvLuJoT5zW483dm4=;
        b=X3mN2kW1Vxjm4pJyh1VG5uQQbIVeljuOdl4+YODWWDCgcHAtGPydBCYRF9tVQIKrRu
         ODjYA7m9ZDgNzJSU3IV9nyLVoxcVIXnSHNSJ+ovjeLFFPb1c1bXCBn1kVmJ68NuYZJ2J
         vdMu3EoKu/LZ/d40D43KPmdE9W6Z7pcG4XmvCGrG9o2QbXkJUD3UhACUsyX1zpxZoAu5
         D7p8NV79v7W/aLLNjmlOIdzfa1d9xgdEak/9FGP/YUuhmvfhvsg55nfXLZUzOaNHNnVW
         uEDSbeXpwYfa45pGigiqlWYQCpjrd8bPZb0VOizTcSBXiVcDRihLSgQoaX/m/GzdkoCk
         ZR4Q==
X-Gm-Message-State: APjAAAUk45yatOfygM2wj7AwhVjMFlk9wxLa1lc4Ff94SupDvFxWrNB7
	EyadKs9mIPUZaW8sg/91cMxUBFa7Y9Vqn9dj8agFYSFHtNkDQrEBq8zatiBieTfjSoclpBkdCDj
	5ig5PYY/0dP/6UVO6LuK+lzBij4FclOkoKILzDuwFH3m53ey0IKaaDndC7bXtWMzsBg==
X-Received: by 2002:a17:902:a70a:: with SMTP id w10mr55391503plq.250.1559940009915;
        Fri, 07 Jun 2019 13:40:09 -0700 (PDT)
X-Received: by 2002:a17:902:a70a:: with SMTP id w10mr55391464plq.250.1559940009156;
        Fri, 07 Jun 2019 13:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940009; cv=none;
        d=google.com; s=arc-20160816;
        b=xxcpVG0USvUC1ncr76VjMtFtBP80wSOP7oYAZrIOd/WEjNmMxGrbXYkR9Uob3AjnCM
         n0aqZCTNBhxFCo3TpY1gzQ+4HyqLG/cv7CHTIxDMEwy6FsT6pfT4RCaaiLJLzv6xgQGP
         GytmnXAe8BP5pPpG8JIPrk28xOFgnuSEeTSpADvqtEBseZvBIQbTyUh1FIl5Z0R+5dBR
         GN6RpaVNYPZEIJVliNH9hNcviZ8AJD7iqYTseNrtp9HaPcn98g6GNNu7HR55O6fLuyx0
         /EASOfrNy9L1V++FeOu73PC2Vp2hIQl0gJ9OwVv41yzLH1JQdC2CNuvEmVUWWrgSSuwU
         jckA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=/zXZ0PAO7hrTuftMmJADCccAFJNVvLuJoT5zW483dm4=;
        b=o/TJJlcy377IzjltJUFFgAlZ0LnxR0plLhxPXz1WzvQy5y8POe9Sqm+eZsHCOfg6+n
         vdBshpvCH2wAa1re7XITqoSEq3goKXvX+cLxA+sJ5lxUYtJg4H70pIA9cQ8gTvC6wFTG
         lCPQtNVJrmWnAI3V8no32ONN1TPusi4o281e4WdKq9xiWAOuhu/3zV9QZ4dQgSrh1EJy
         26rC9I6b6bxBjKMgRwryXZJkoRVDYZmafFN1WjlLdNUv8V/LcuJn7LCnHfqSIHtsGaGo
         OzxB+Ee2TQkT3XyRA7/cYD3c7bILzRnTsSzdNNtoe/usRBVdl0jFvhaORcDjAcNbZ22X
         pkbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=xrvdgiwg;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor2956044pgs.32.2019.06.07.13.40.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=xrvdgiwg;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=/zXZ0PAO7hrTuftMmJADCccAFJNVvLuJoT5zW483dm4=;
        b=xrvdgiwgMy+n6sUxDDjF6GbcFmqZ9IbL4LqbaOlUjeE8uqFUu4xLwLCn5TySJGkcHl
         fXPiABlcfNSCw9bl0NwfmBnfApC4fAM1xXXJDZ27D9KyYVvW3Pd4X+nasECUMC2LBZEJ
         fKA5BQIw1BcsTounoXppfOwxaeXfpEVX0HyHm3x1KFjINzS4PCb6c6IaljqNaSCBm7Od
         drrmRGWCxY710x1mQlxy/KRBEo0C1hie/MUbVm5jM/+AlavFNb6N+fUr8V+MNbUOPbuC
         xC4rbQBCWUzb43kM79GQ/pk24o4zNJi31I1dPZeQMzNZkLkM+wXFQ8x1bMx3nK65vvQb
         mnNQ==
X-Google-Smtp-Source: APXvYqw9CMgTx+uPCBp2eShznieLWxzWHpVNj71rqNoWul6wN77odT5+ocrO71ob0NcUvASo3obsmg==
X-Received: by 2002:a63:490a:: with SMTP id w10mr4721938pga.6.1559940008694;
        Fri, 07 Jun 2019 13:40:08 -0700 (PDT)
Received: from ?IPv6:2600:1012:b044:6f30:60ea:7662:8055:2cca? ([2600:1012:b044:6f30:60ea:7662:8055:2cca])
        by smtp.gmail.com with ESMTPSA id 128sm3433146pff.16.2019.06.07.13.40.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:40:07 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
Date: Fri, 7 Jun 2019 13:40:06 -0700
Cc: Peter Zijlstra <peterz@infradead.org>,
 Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
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
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D10B5B59-1BE7-44DC-8E91-C8E4292DC6FB@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com> <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com> <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 7, 2019, at 11:58 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 6/7/19 11:29 AM, Andy Lutomirski wrote:
> ...
>>> I think this new MSR probably needs to get included in oops output when
>>> CET is enabled.
>>=20
>> This shouldn=E2=80=99t be able to OOPS because it only happens at CPL 3,
>> right?  We should put it into core dumps, though.
>=20
> Good point.
>=20
> Yu-cheng, can you just confirm that the bitmap can't be referenced in
> ring-0, no matter what?  We should also make sure that no funny business
> happens if we put an address in the bitmap that faults, or is
> non-canonical.  Do we have any self-tests for that?
>=20
> Let's say userspace gets a fault on this.  Do they have the
> introspection capability to figure out why they faulted, say in their
> signal handler?

We need to stick the tracker state in the sigcontext somewhere.

Did we end up defining a signal frame shadow stack token?

>=20
>>> Why don't we require that a VMA be in place for the entire bitmap?
>>> Don't we need a "get" prctl function too in case something like a JIT is=

>>> running and needs to find the location of this bitmap to set bits itself=
?
>>>=20
>>> Or, do we just go whole-hog and have the kernel manage the bitmap
>>> itself. Our interface here could be:
>>>=20
>>>   prctl(PR_MARK_CODE_AS_LEGACY, start, size);
>>>=20
>>> and then have the kernel allocate and set the bitmap for those code
>>> locations.
>>=20
>> Given that the format depends on the VA size, this might be a good
>> idea.
>=20
> Yeah, making userspace know how large the address space is or could be
> is rather nasty, especially if we ever get any fancy CPU features that
> eat up address bits (a la ARM top-byte-ignore or SPARC ADI).

That gets extra bad if we ever grow user code that uses it but is unaware. I=
t could poke the wrong part of the bitmap.

>=20
>> Hmm.  Can we be creative and skip populating it with zeros?  The CPU
> should only ever touch a page if we miss an ENDBR on it, so, in normal
> operation, we don=E2=80=99t need anything to be there.  We could try to pr=
event
> anyone from *reading* it outside of ENDBR tracking if we want to avoid
> people accidentally wasting lots of memory by forcing it to be fully
> populated when the read it.
>=20
> Won't reads on a big, contiguous private mapping get the huge zero page
> anyway?

The zero pages may be free, but the page tables could be decently large.  Do=
es the core mm code use huge, immense, etc huge zero pages?  Or can it synth=
esize them by reusing page table pages that map zeros?

>=20
>> The one downside is this forces it to be per-mm, but that seems like
>> a generally reasonable model anyway.
>=20
> Yeah, practically, you could only make it shared if you shared the
> layout of all code in the address space.  I'm sure the big database(s)
> do that cross-process, but I bet nobody else does.  User ASLR
> practically guarantees that nobody can do this.

I meant per-mm instead of per-task.

