Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4148AC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 08:48:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD047208CA
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 08:47:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ERD2Hjon"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD047208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20F936B000A; Sat, 27 Apr 2019 04:47:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BF296B000C; Sat, 27 Apr 2019 04:47:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 087A56B000D; Sat, 27 Apr 2019 04:47:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABA466B000A
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 04:47:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b9so6062393wru.11
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 01:47:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/zv5yuIaeqOlk8OEMKio4/MAmsvMLSORpRGpKpNIa0M=;
        b=NyDxrJizr6KEcWwYuQaLSwgY1WylWt0nVlv7/FV9gyn6LLulHwZE5qoJR/m/DvF10a
         xVwheLRS6dWyGMH+DqHue1wrc+W6NOypzjIU98gL/7GiZmVp8QRlVBlEm1vhxRN49R/i
         RyUeeAxvKCFHrPobwrGMzvoxxTku20YgkhhriudPydvBuaIRjYTsDsjx+3lpJ4T3R15T
         QELIaVBWm2NDyKxECWXpRQSHHNMK1ik/Xevgacv3iUqdzj8CHDi1qcI15hHRJ6qw3S34
         nOaojsaHfwx298J1veKy07SBUiy/EqFTmlcChJdtvPyXX2zxdJdw7LU5fY1a0QOFxhfC
         GAqQ==
X-Gm-Message-State: APjAAAVo0C8ihh7X/Ob/g3yeWyRA39IPVsv9SPDjmlfSAaIXan8ytvYW
	tKXXAOF7YmKALxIYJ1izti5rLuqSj4CkI9J7IW3hxT4yZIqg4k//wWE/pNZ2qVE/RHAL+xg8kM+
	9O1X7cCa2EIBqmkuDN/L0XYFEAFVNSjvs9EUAh2v1YqKTpCJGXMIcGCCGQMQ+mK4=
X-Received: by 2002:a05:6000:104:: with SMTP id o4mr3023040wrx.106.1556354878024;
        Sat, 27 Apr 2019 01:47:58 -0700 (PDT)
X-Received: by 2002:a05:6000:104:: with SMTP id o4mr3022987wrx.106.1556354877086;
        Sat, 27 Apr 2019 01:47:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556354877; cv=none;
        d=google.com; s=arc-20160816;
        b=L0RwHPLpLGFCPNAdkGVvXttNHPSziacmgEs855kErdZZvFK02zzhzqGrsEcWC6Xl2+
         lEsMb6CrlGfI2R1CE9dmMMdo8XD7BUwVfw1pSv9YhvTvCPF5WuMZrmc/Ws62jqU5O+4t
         i/wP/wfND4R8CcsinA/r4Lob7effAAmmoXDi0O1C0FZucUKDeSv9LiLJc74Qwh+caZWa
         IMlxqAnV4jJNYQpn26gb4OIzpiUIGUGomokKVB/DhpfK9Eo0CBi/bCg4dNPHyYC0fae0
         x+/jDcWzxiUQwQrqCKgVwCyv6k8Hw5V1WIh710IAy7z5QmaSTCFKttxqDbLYkKpHs+zD
         JGJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=/zv5yuIaeqOlk8OEMKio4/MAmsvMLSORpRGpKpNIa0M=;
        b=j7jxGFyT3yXofsNyqsR2ozimK/kqsw5i3pQjcsED83J5dq3E5sEQJhLAcBTl8dioUk
         8rl2Jhy8RfbyARxxy1cSEZTkq1+s8i93R9UgUn40vc107PWGaHNoMKvSzlkfsxfeGb3j
         beDG88l51jl+0rt44ofdqfftbDYUrXlxg++ecj9FS/GfDeC/eyq9fzaZG7nVvK1QuSkF
         e+FRRjGtpE5UHOoId4VypKrs7jm2Aj+OJW7MwdrFKyl0B3+bDz6lqBXhdrm8tNa0A1kb
         r+KMD/cbmZYu60YwcR/5PFw4ziU1uNVg82oQZwF5t4MEse2xsJkd3jii0Duu1U0d0v8y
         qLEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ERD2Hjon;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17sor15503120wmg.15.2019.04.27.01.47.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Apr 2019 01:47:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ERD2Hjon;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=/zv5yuIaeqOlk8OEMKio4/MAmsvMLSORpRGpKpNIa0M=;
        b=ERD2HjondX4lBfKJLBLv2Ss5GXQQY/STVBfBPYT50ndwhwjcnyhGpzKBcY+P/5gqVX
         w39JEIwrjrv1D8YsV6gZaMSlv0/aPtoDVw4XzB/u66gtqut4JfKoKqsbemJ1J6nZvea5
         UiDPM58uIPtco+tUA8J3RZmOjIECRVxK8EYwLbB1YWRMQuOdZlsaZCb70X4enzQJreJC
         W5zQ9ei4PVkSjhEWsVUUeCfsFCeB2DxGsfcX6ZKw0wIx8NHxSGAnOMVVgGF0YfA2nTN5
         P0LSA84kLOwfiAkPj8TA6dbAWkxPO2EjupV1We6AwPXETRj923vp+j4kHSclcKFS98JM
         53PA==
X-Google-Smtp-Source: APXvYqx7ZHqoLPTZteFydYJTzzPWBSczcrfxeg7zOhMoGoDZ6X/mErWp4KPIp06cwHTPRrgKIYe+iw==
X-Received: by 2002:a1c:9942:: with SMTP id b63mr11267225wme.116.1556354876436;
        Sat, 27 Apr 2019 01:47:56 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id v192sm27592490wme.24.2019.04.27.01.47.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 27 Apr 2019 01:47:55 -0700 (PDT)
Date: Sat, 27 Apr 2019 10:47:52 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190427084752.GA99668@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
 <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Andy Lutomirski <luto@kernel.org> wrote:

> > On Apr 26, 2019, at 2:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> >
> > * Ingo Molnar <mingo@kernel.org> wrote:
> >
> >> I really don't like it where this is going. In a couple of years I
> >> really want to be able to think of PTI as a bad dream that is mostly
> >> over fortunately.
> >>
> >> I have the feeling that compiler level protection that avoids
> >> corrupting the stack in the first place is going to be lower overhead,
> >> and would work in a much broader range of environments. Do we have
> >> analysis of what the compiler would have to do to prevent most ROP
> >> attacks, and what the runtime cost of that is?
> >>
> >> I mean, C# and Java programs aren't able to corrupt the stack as long
> >> as the language runtime is corect. Has to be possible, right?
> >
> > So if such security feature is offered then I'm afraid distros would be
> > strongly inclined to enable it - saying 'yes' to a kernel feature that
> > can keep your product off CVE advisories is a strong force.
> >
> > To phrase the argument in a bit more controversial form:
> >
> >   If the price of Linux using an insecure C runtime is to slow down
> >   system calls with immense PTI-alike runtime costs, then wouldn't it be
> >   the right technical decision to write the kernel in a language runtime
> >   that doesn't allow stack overflows and such?
> >
> > I.e. if having Linux in C ends up being slower than having it in Java,
> > then what's the performance argument in favor of using C to begin with?
> > ;-)
> >
> > And no, I'm not arguing for Java or C#, but I am arguing for a saner
> > version of C.
> >
> >
> 
> IMO three are three credible choices:
> 
> 1. C with fairly strong CFI protection. Grsecurity has this (supposedly 
> — there’s a distinct lack of source code available), and clang is 
> gradually working on it.
> 
> 2. A safe language for parts of the kernel, e.g. drivers and maybe 
> eventually filesystems.  Rust is probably the only credible candidate. 
> Actually creating a decent Rust wrapper around the core kernel 
> facilities would be quite a bit of work.  Things like sysfs would be 
> interesting in Rust, since AFAIK few or even no drivers actually get 
> the locking fully correct.  This means that naive users of the API 
> cannot port directly to safe Rust, because all the races won't compile
> :)
> 
> 3. A sandbox for parts of the kernel, e.g. drivers.  The obvious 
> candidates are eBPF and WASM.
> 
> #2 will give very good performance.  #3 gives potentially stronger
> protection against a sandboxed component corrupting the kernel overall, 
> but it gives much weaker protection against a sandboxed component 
> corrupting itself.
> 
> In an ideal world, we could do #2 *and* #3.  Drivers could, for 
> example, be written in a language like Rust, compiled to WASM, and run 
> in the kernel.

So why not go for #1, which would still outperform #2/#3, right? Do we 
know what it would take, roughly, and how the runtime overhead looks 
like?

Thanks,

	Ingo

