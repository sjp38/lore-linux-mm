Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E6B3C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 172DB2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 21:07:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ocallahan-org.20150623.gappssmtp.com header.i=@ocallahan-org.20150623.gappssmtp.com header.b="itZm4mid"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 172DB2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ocallahan.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901696B0003; Thu,  2 May 2019 17:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B0B96B0008; Thu,  2 May 2019 17:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A0AF6B000A; Thu,  2 May 2019 17:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15D7F6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 17:07:51 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id u5so638262lju.22
        for <linux-mm@kvack.org>; Thu, 02 May 2019 14:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:reply-to:from:date:message-id:subject:to:cc;
        bh=McWTtx7Tp7tMDcpgUWURvLH3xAZpqNdcMywhax+H9u8=;
        b=Lsq9oh3z9JBU71rt2fM+glQscSUjiVSv3dK3s1cm7fK01Q1od4HPmWKapkSS8S7Kmc
         6IT2IJ1TliRPr8TdNZDiRBYN6SbXnnYoXVqFZyQ7WxOciKxyXyLGP41i4uKfoDeLYgiE
         SjblQP8ARs9vFO0FO0DZYLdeg8vlM4UENRGrBT3+JhyzQF575GFsIvin6xSlFIj1JQTy
         35u7REmO/UgjMCHRlVDbUoF8R9zgEagDHuuvtPqKyFMfNT3W4w+nAH07inMJCVTnXciD
         HWfWmNb+Se3ais7FqE6M+F+DtiysqpbkbW9Kt7nntSK5fUO/UW6SREcxlD6/uIpn2bDL
         SxMA==
X-Gm-Message-State: APjAAAW7Y6+sGpSP5eBQ2rLJLDfAVk3APzeQRiwdZK4gTCFFnQRS9Z79
	0SDPHe9UsA7VVrCoixIlDFTYjiXLBxTO5+ySIFYd3Z1rwkrER/qi0UhY/putSfbIBRePcHCHKbt
	H5XuWOB2lGYi71LrCFkWUpB+jc25xapd9/sNBCYeTZEC9I7jGde9183frl5Ij/Ow=
X-Received: by 2002:ac2:545c:: with SMTP id d28mr3049848lfn.144.1556831270543;
        Thu, 02 May 2019 14:07:50 -0700 (PDT)
X-Received: by 2002:ac2:545c:: with SMTP id d28mr3049813lfn.144.1556831269508;
        Thu, 02 May 2019 14:07:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556831269; cv=none;
        d=google.com; s=arc-20160816;
        b=U65+lSkjIS+pQWj7jBJtAajqyLkEMTakn7NXraFpPxfrdZleZJGDPyATPR+8c8gWO6
         btTgLcuy1MYUKYh1syfuY6YGI5KPiJWsoO0touwRFw51yAsRPzS84YDMmAeLAi5xj9Kw
         boBAHY/pZPBCN8GXtcI2Obt8QqhWSqqijnDxgcYP48eCp3aRia4PxEfV5X0ZDw/E1JcE
         Sc/0o0c8CPL2NcreKP1LazGWRWD65cRwCEX+65YAEKXqtmXcMzzqQKOMHCoxlP/k1fC5
         Pw/cs01bxnZPibvWrxumCMaBSTmjr2G4sVWsg+u+3pgOVBbcy0iyJ2ycD66XqwFRYIqZ
         85Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:reply-to:in-reply-to:references
         :mime-version:dkim-signature;
        bh=McWTtx7Tp7tMDcpgUWURvLH3xAZpqNdcMywhax+H9u8=;
        b=GUZAmNyGgHTR8FNGa+YpLuuL94HeZsLAzq8/simxj65pAWS+zRNCQE21Y4wO4uFmvV
         MaUxiBncrLw7Ne80M8WQxa+KvxAc0lSUZBMeZ+LZgeUA690mKHpddUPhVM5S6w1LqpEo
         QXVCHebnJ38G2M8fc5L+N1UVhwBJPnYH0Hat+qigp2NsJ+B+l+fmTGvE2Z09j4XLJRLr
         xjDxJR3gpneCzSMu6xlgBKxWFVB48XetSZqjqLky8EIi8HxGfadoSP91VluSGo1zcNDs
         YX7iKKgBcrydqI/r7OZkF5Id0Vvx1pu7i4hP1d+0CGFaLm+7f2ozuTKuhKRieDKqyZWs
         6N/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ocallahan-org.20150623.gappssmtp.com header.s=20150623 header.b=itZm4mid;
       spf=pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rocallahan@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor95303ljn.21.2019.05.02.14.07.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 14:07:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ocallahan-org.20150623.gappssmtp.com header.s=20150623 header.b=itZm4mid;
       spf=pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rocallahan@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ocallahan-org.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc;
        bh=McWTtx7Tp7tMDcpgUWURvLH3xAZpqNdcMywhax+H9u8=;
        b=itZm4midVgkaAhNA0r5PfpUHd/gPvPcK3n8NB1YcbOEZ483aEikD/V8xjhyy+P9+G3
         O7NWH6/7GmLn6LJLpEDCkVpkGs9kJ/xe/mv7xm8wikmwI4fYP7sz53GAq6W6EHAYb1HD
         GqBFjxVO0csXNMBnth+6rtohGNFewYALcIuzyvwgO3fM9P1Cf/LDHEdEHRym28VQKEfU
         HS1nlAec0MXtaXmT+tTwRyVPDIO7VWRcNB1+erwL//zEH8yVqp5XR08kdi5xnGhUODif
         ltBMyBk20L0/nvjVz/Sz0sBx+AUjiAvNW4mSXVxcvNqlGkxwD2PFsXFgAP7gq01Jbfdy
         UVbg==
X-Google-Smtp-Source: APXvYqx6SA6ZIHrK/cbob827p2TujSQac7Gf4FVBIEMUw8EiLG7mK+9ScmPjMrhhS+WzT5pz6bIPktW8RUiWcpMHi5M=
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr2765684lja.49.1556831268788;
 Thu, 02 May 2019 14:07:48 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com> <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com> <20190427104615.GA55518@gmail.com>
 <CAOp6jLa1Rs2xrhJ2wpWoFbJGHyB99OX9doQZc+dNqOSUMgURsw@mail.gmail.com> <20190502152016.GA51567@gmail.com>
In-Reply-To: <20190502152016.GA51567@gmail.com>
Reply-To: robert@ocallahan.org
From: "Robert O'Callahan" <robert@ocallahan.org>
Date: Fri, 3 May 2019 09:07:37 +1200
Message-ID: <CAOp6jLYAksmUN2EzZmu9qOkUgPS0=8t0w1zgCWrmhhOf16Fr4Q@mail.gmail.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Ingo Molnar <mingo@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, 
	Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 3, 2019 at 3:20 AM Ingo Molnar <mingo@kernel.org> wrote:
> So what might work better is if we defined a Rust dialect that used C
> syntax. I.e. the end result would be something like the 'c2rust' or
> 'citrus' projects, where code like this would be directly translatable to
> Rust:
>
> void gz_compress(FILE * in, gzFile out)
> {
>         char buf[BUFLEN];
>         int len;
>         int err;
>
>         for (;;) {
>                 len = fread(buf, 1, sizeof(buf), in);
>                 if (ferror(in)) {
>                         perror("fread");
>                         exit(1);
>                 }
>                 if (len == 0)
>                         break;
>                 if (gzwrite(out, buf, (unsigned)len) != len)
>                         error(gzerror(out, &err));
>         }
>         fclose(in);
>
>         if (gzclose(out) != Z_OK)
>                 error("failed gzclose");
> }
>
>
> #[no_mangle]
> pub unsafe extern "C" fn gz_compress(mut in_: *mut FILE, mut out: gzFile) {
>     let mut buf: [i8; 16384];
>     let mut len;
>     let mut err;
>     loop  {
>         len = fread(buf, 1, std::mem::size_of_val(&buf), in_);
>         if ferror(in_) != 0 { perror("fread"); exit(1); }
>         if len == 0 { break ; }
>         if gzwrite(out, buf, len as c_uint) != len {
>             error(gzerror(out, &mut err));
>         };
>     }
>     fclose(in_);
>     if gzclose(out) != Z_OK { error("failed gzclose"); };
> }
>
> Example taken from:
>
>    https://gitlab.com/citrus-rs/citrus
>
> Does this make sense?

Are you saying you want a tool like c2rust/citrus that translates some
new "looks like C, but really Rust" language into actual Rust at build
time? I guess that might work, but I suspect your "looks like C"
language isn't going to end up being much like C (e.g. it's going to
need Rust-style enums-with-fields, Rust polymorphism, Rust traits, and
Rust lifetimes), so it may not be beneficial, because you've just
created a new language no-one knows, and that has some real downsides.

If you're inspired by the dream of transitioning to safer languages,
then I think the first practical step would be to identify some part
of the kernel where the payoff of converting code would be highest.
This is probably something small, relatively isolated, that's not well
tested, generally suspicious, but still in use. Then do an experiment,
converting it to Rust (or something else) using off-the-shelf tools
and manual labor, and see where the pain points are and what benefits
accrue, if any. (Work like https://github.com/tsgates/rust.ko might be
a helpful starting point.) Then you'd have some data to start thinking
about how to reduce the costs, increase the benefits, and sell it to
the kernel community. If you reached out to the Rust community you
might find some volunteers to help with this.

Rob
-- 
Su ot deraeppa sah dna Rehtaf eht htiw saw hcihw, efil lanrete eht uoy
ot mialcorp ew dna, ti ot yfitset dna ti nees evah ew; deraeppa efil
eht. Efil fo Drow eht gninrecnoc mialcorp ew siht - dehcuot evah sdnah
ruo dna ta dekool evah ew hcihw, seye ruo htiw nees evah ew hcihw,
draeh evah ew hcihw, gninnigeb eht morf saw hcihw taht.

