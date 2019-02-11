Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 995CEC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:32:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56C4C218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:32:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jDVIlylH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56C4C218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D364F8E0156; Mon, 11 Feb 2019 15:32:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D19F38E0155; Mon, 11 Feb 2019 15:32:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD4BE8E0156; Mon, 11 Feb 2019 15:32:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 934FB8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:32:45 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q20so185629pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:32:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=LYEtQ0huIgRqRN72HKrMf6/t6SbOdkntokaFuVtRuwA=;
        b=BzOiwIGZsz71k5N2hEzd3+eOQEUBfJeYq7UdJnF3ZlVEP+s3TuhGuzcn00uBpdZJ6n
         U1b/XdeoWWLE0Bdw/SxX5fsKE/YusWy1EDKANWsOTDAh82/yxVLBNd7L13MK8fKZREFW
         /g2hno1IIbA2IUs34WqJax1c6jewpJQKIRpZyMmySUjGBrd0SAmpFRkaOASM9Sr3ZR24
         k/o1lKV2ag4hhkEWlUKIE2jxRZx3eWRHWPsHG1i/sKJmLV4irfnZ90mmV9Y9gh0SLpfW
         PT15m23JDs2eY6fd+r29eAsFKiCOHMAPEzb8Wyx/zsUVQyR+NfUoOOY9Copm9aOCMOt3
         BvIQ==
X-Gm-Message-State: AHQUAuYPTzShRJkN3vt9/wIsPc30TKahrOry4Azighgyw63Pk7g3PlfC
	gePYcXO66AAKo2v1IChi+1G2u9CXde4RPWp3AQX7CfvWoWZjuq3WatzmTju7XEIuYDbugPSwL9G
	k107IbxMe2Y1SbcRnk59i+7nxuyxoinNTcoD7QVJqXqVFEO+q/phI0ByezZLa3D2CfK8AX12D9L
	pljs3FMQxP5A+xvWp7BX/3qw+I6OOh6KXcIh3wRyehjThMhNnkyWTxtnmofldTVkD4n7JyMurmC
	PtFTuyHvLHdLwMAWZ7D/OriE+jC30CUM4MccCKfT2DN1low/NaapJ1yTSUHM20TvFksonSohoBl
	/mIMV2IiGZWaRiAWJiVzWNnaiSZpSAb+A1nnrwFvRpUnkj/ymqZ24x++Qu96FvZKA665AHPe3Mf
	r
X-Received: by 2002:a63:184a:: with SMTP id 10mr59863pgy.81.1549917165187;
        Mon, 11 Feb 2019 12:32:45 -0800 (PST)
X-Received: by 2002:a63:184a:: with SMTP id 10mr59820pgy.81.1549917164539;
        Mon, 11 Feb 2019 12:32:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917164; cv=none;
        d=google.com; s=arc-20160816;
        b=QR0kzs7OSGcUp9Ltp2gDWDkV+ov/AaB486KfAtt0Zp2CQr/Xu52ERyLvEdy8vv9tN9
         XIDPhP5+IN89iQ4qrT5A2D0YjLJaPQ8b5awOTzuhuDGLX2sUKUAylMFwGpHt9j/rsBYs
         6kWx/HsNlsmWuqvSWHR+P6b1cjVmwjkqgJlLIHgR9iGln5ezQQMCA8F+FBspQqK8gk1S
         FNUK1LZnAiq9p2IEKtCcRTXehhnDIxSgUGk5jT9PxNs/qNmQHknmqeUNGaHkGORaauZZ
         jcbNJCUKl5Zy2XW6fFxmBlb2iXQEhFKqqAuVLtH+Xvx/N5nutZbkUx/M8Qm09ghzI93I
         MbaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=LYEtQ0huIgRqRN72HKrMf6/t6SbOdkntokaFuVtRuwA=;
        b=XjWPit2PylPuvhJf3h2BgBVBMX9GGmjBtzUB1n2jZa2SU+Ht7yYobhhjIeYzD8rbSw
         DU0bL16f81qnfJ0UeVrwOAnXxpmo/R7o6fgPw2fEuVP9ur5oQ2PYD4kJVEQ7tY5iNBol
         fftBEItEegrtpvVlgWbjilRLZRnw9gBVplHi65oDfRZftWvoQxovqfmKoA7KMCZnKa+S
         cK4H4kdyPS6dsDsQcOLtvrWrSXC35sKgb4YNC5qrwhYA+n7xNAfw24WeZEzsMn1kHIOl
         vEhX6fxqcph2efgCODKYL8O9OSpNZYQUi+UsgEo5iZBOgHD/jEwy/U0r7Xd1r91kY6s+
         uIcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jDVIlylH;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14sor3236666pgf.79.2019.02.11.12.32.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:32:44 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jDVIlylH;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=LYEtQ0huIgRqRN72HKrMf6/t6SbOdkntokaFuVtRuwA=;
        b=jDVIlylHgLecqgbUr9f9MSgPipvsjbdmdR5Ccr2YQlrg8Dl3zqXWhKCYsO4R+DrurX
         7hYnNc7fJOMhgnQXkTxvObqSsJdhA/mCfjYLko+GOmny8Nx+Oqul4Zl47Vws1RT5rvb2
         VkSxW3G7r66YWNusKQi1YYB1tqYKEStyT1xd7ee/68a8W21/5rfFlIkYQitSNbAgpiQN
         r2JetYqDze242ZhQyJy8JJrrOhQXIaJXFOMdOTCgTNJTzdrHXaO010kBDmABT040pMGM
         ub8BvmNjymWv1dZyTxhLNANe9rda/SV4OTHtRTTKcxnrIgvLnJvd7w4IETjI0SKnVdpj
         uuew==
X-Google-Smtp-Source: AHgI3IY/t2t2yc8abbgd4X3ggvCGVF2OGRCQro2+hmH3yq84NbHtsVFoO6+n44jfzy8/G4hRQTyUTw==
X-Received: by 2002:a65:6684:: with SMTP id b4mr64478pgw.55.1549917163761;
        Mon, 11 Feb 2019 12:32:43 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id c23sm12753759pgh.73.2019.02.11.12.32.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:32:42 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190211194251.GS19618@zn.tnic>
Date: Mon, 11 Feb 2019 12:32:41 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
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
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@intel.com>,
 Masami Hiramatsu <mhiramat@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A55214F3-CDC0-44C4-AFB6-7E8E23CC6F85@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 11:42 AM, Borislav Petkov <bp@alien8.de> wrote:
>=20
> On Mon, Feb 11, 2019 at 11:27:03AM -0800, Nadav Amit wrote:
>> Is there any comment over static_cpu_has()? ;-)
>=20
> Almost:
>=20
> /*
> * Static testing of CPU features.  Used the same as boot_cpu_has().
> * These will statically patch the target code for additional
> * performance.
> */
> static __always_inline __pure bool _static_cpu_has(u16 bit)

Oh, I missed this comment.

BTW: the =E2=80=9C__pure=E2=80=9D attribute is useless when =
=E2=80=9C__always_inline=E2=80=9D is used.
Unless it is intended to be some sort of comment, of course.

