Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D49EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D1462229E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f5tw/40m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D1462229E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF5098E013B; Mon, 11 Feb 2019 14:09:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3798E0134; Mon, 11 Feb 2019 14:09:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1F168E013B; Mon, 11 Feb 2019 14:09:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEE58E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:09:33 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so9034175pgc.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:09:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=nXXWwRuaJ6+ems3kM7ee19N3t7IhdXW1WW/p2CXVYdI=;
        b=XfRpDNais+x6oNnIMdw+pVH6nd5fdmmaRHdRHBY47kw0gS0mTlvywVuxeynQq27Rao
         sW6s2rzqsYTqKEP1Nc+/R/l4KbYo8AHqjULTwnwNgQHJho9XD21ZwVPSMPNp5WNjJ0YV
         8K7ZoiHK+fWkTahWbBcfweYu4EVyrLpJgdXEDLxDSxySEGO7qReWvYsgHFUL+s6qZbI9
         Y1zEk87fu/SqwMAifnqXegQ57XC/AZtnWcZP0+jAjtD6ngOBDPwfPAmCslfn4MECRN8c
         T+nVlm55iiFZRhMarDvz7zIdmbGz+FgAp6adA7Cjddbz0ZZt2lL0OuTHxdAOYfcBKWvk
         QRtQ==
X-Gm-Message-State: AHQUAuayWFAbdXxikAqZIcsAtvkQ8CzQVvSYcXIu4rclAncebdZLT3RC
	9AZtExZL3bWK2F61qiGbFfIic8e1gMI1sYZcyk79xiteMLXOFmXKH7qnmIdLAwFQVX6CgRMoRlV
	UrA6OdWopKyH5DEmNevuzQH8IBLYEQvxAeb85KTe/Bu40EbnqrxoJ/Sij9uYwNMyb0dD7jM/Mzw
	xw9K+/nO/P1F//D5OyTc8/7A4yhePnHtw650XacAq9enyXMsv7W3A4Ok1PdUypw0zfD3fu06fvL
	95Rro1xCjMzPWaVcIGIMguu6hB9d2pj49RJMgo660xPegKCypqZqO16QLM0h17hJITaFbZsP7et
	8fSRB8krStfCQoyrvvWpURrIPobeSxdyglfeH9nDXQOjmCGKSocHgOpSgdXC0eOXVkLGyUwHk1g
	o
X-Received: by 2002:a17:902:2ec1:: with SMTP id r59mr39506413plb.254.1549912173010;
        Mon, 11 Feb 2019 11:09:33 -0800 (PST)
X-Received: by 2002:a17:902:2ec1:: with SMTP id r59mr39506367plb.254.1549912172429;
        Mon, 11 Feb 2019 11:09:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912172; cv=none;
        d=google.com; s=arc-20160816;
        b=Pz+hWXVt9p3E/mjn7j7/RWYqgn3E69RCBqllXmpb6hm4Fk+Cc8j4MbfpcAsBuuSbhd
         77ANiyKITXrAD0DzqoQsAqLo2M8AQmucl1mGc+eq/K7dEDyCJEW9iW9DHogh+OunQimd
         Vm4D/8YekmjK5vcUl1FC23baIYIG2luKXZSINCWt+5RbnuvypLiT8ONsMQSdWzQYehsX
         VmTfMGjgrE+H8QULErWjvJSKED4ch1044vs9lq2rAh9X7FeKFD3R/M7cbUMzMoiTjW2J
         I6vHVjkwCAn1vmZ/+KUEjarCkFiZYQGMFXFM8dJUtqqWudazDB85SqmDFes7qBFpJrJG
         5fDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=nXXWwRuaJ6+ems3kM7ee19N3t7IhdXW1WW/p2CXVYdI=;
        b=s0d4d/m6BfrgO/FfXhQEc6pyjkzYZi111H+VaEpRZmA7++ObPsx3zNsL7HI2An9VLn
         C0IUGc3ejjG73lyXGJnADo4y6Unmco3uG9tTNryK6pzgq6yAJQumLBV0nzU0Z9cHwzKy
         PfCpCrCSY17OtNIu4oEB2vCjGoo1K5cXqVLWX8+I4bHY8c5v7mBEC8a6772cLONY9Tlc
         CYKr4tdv18QBiWufjkOIB8C2P6XpoUVfsbU0GmCgeL6yZroGof3/BBXL1oJSDVDSbvIn
         801fq2GJVFPHnzXokdh1aulZl61+9ny4GRAow4Et58guhvR/lsUEWkSlM8UZXmRus7HD
         mNwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="f5tw/40m";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor14869685pgc.14.2019.02.11.11.09.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:09:32 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="f5tw/40m";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=nXXWwRuaJ6+ems3kM7ee19N3t7IhdXW1WW/p2CXVYdI=;
        b=f5tw/40mwGuzkdOcN4HgctENimk7IRkUtncSGUWBNxDfImzcfpFsSc/X2DOrcTTZ3A
         n0LbnvfXS7EVdDtkI/WPQ7IIjassAhqHIEVRy0c3cmH3zmtXgj3WdNJbc8kaTzTRzaqE
         0Rkmf1uLlb/c4Tij/veYAEwld984BfNK6Ze2hcTrtWqKjpHDo16VbqPp6veoBC9kDcet
         R2f4dlLxSLhTx/PL3c/S084cipdpplX0FmsL0nLr3Du3QKb6NA7aVAtMjZ5pyGT2C65J
         CWJvHJsvyIJgLBV62FRx2aregf9ZQXjCbrTIO2Ma29AhKazy6qBW6cDZQhqz/63XTFzV
         DuGA==
X-Google-Smtp-Source: AHgI3IYG+m4zIDVNNPmj5+E7N+OOV6khCxg17Cv7p6YOyLv1jkwlRprnlmBQzhLqEvhRByWMnrU9nw==
X-Received: by 2002:a63:e051:: with SMTP id n17mr35005871pgj.258.1549912171925;
        Mon, 11 Feb 2019 11:09:31 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id a15sm16655637pgd.4.2019.02.11.11.09.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:09:31 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190211190108.GP19618@zn.tnic>
Date: Mon, 11 Feb 2019 11:09:25 -0800
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
Message-Id: <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 11:01 AM, Borislav Petkov <bp@alien8.de> wrote:
>=20
> On Mon, Feb 11, 2019 at 10:45:26AM -0800, Nadav Amit wrote:
>> Are you sure about that? This path is still used when modules are =
loaded.
>=20
> Yes, I'm sure. Loading a module does a gazillion things so saving a
> couple of insns - yes, boot_cpu_has() is usually a RIP-relative MOV =
and a
> TEST - doesn't show even as a blip on any radar.

I fully agree, if that is the standard.

It is just that I find the use of static_cpu_has()/boot_cpu_has() to be =
very
inconsistent. I doubt that show_cpuinfo_misc(), =
copy_fpstate_to_sigframe(),
or i915_memcpy_init_early() that use static_cpu_has() are any hotter =
than
text_poke_early().

Anyhow, I=E2=80=99ll use boot_cpu_has() as you said.=

