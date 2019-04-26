Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1609FC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE3C9206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:30:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XPVgj3+q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE3C9206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08F5D6B0005; Thu, 25 Apr 2019 20:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 041246B0006; Thu, 25 Apr 2019 20:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E97C46B0007; Thu, 25 Apr 2019 20:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B12936B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 20:30:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a17so1004438pff.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=112d0Xs8rSgYB+ol4sBKoXelDAYKs2aw8MYQMbZsz4M=;
        b=gNI+FDdg740Ht5pICjE/Pk9KiEi0QY9YtZCEX2veHKSc9GHiGH2U1pPo6+2N6KHKLb
         WlFU7IyAGH6SYSCNMg1csXrBjqI3iJFagi38p6g4/AW8PQ3rAEpssPVnkTwqzRqgjvaw
         hNr1GS74WVyoRSRcUpWV3TS0zuSU9hmOnEY1pft7c8zwXY0Jo7J2+RAQ4NoTczFSlQFI
         /MK1HbyWT1E1eGngFhEaHA1LRzdxHRT0ZnPU10Osl+FAy2P69p/RnFUGYEPvXENC6T96
         DIpLIGE5yLt9kmcs9QxklTIIbsDQc1xrlG5QW1X+9hBnlTIG9A8Czm0TfKPNX9yCQP5A
         uYTA==
X-Gm-Message-State: APjAAAUK3K2riubkXX1xdKhVptlx2lfkneh/QEfyiZfS/CCDri17JdyN
	FzckuisHB0XqxiCsVD/xYffN3fT14/yIAS5scViZVFyJRQiNooqaZdOY5qa1lJtciG/bBSH9Vyp
	JyQuJDmcj6qNkga2s2ZxHFW8fg/PKfdiW3WCXj06gqm0fXTIO/I7BulNm8M1J/G3msw==
X-Received: by 2002:a17:902:f83:: with SMTP id 3mr22296011plz.55.1556238628276;
        Thu, 25 Apr 2019 17:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztkaxmbtV9mRa4pCOPS5pZxafVJdjvxpJorsak9+0BB5HJpzbLemTudxNQKNC9Tym0IN9C
X-Received: by 2002:a17:902:f83:: with SMTP id 3mr22295924plz.55.1556238627300;
        Thu, 25 Apr 2019 17:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556238627; cv=none;
        d=google.com; s=arc-20160816;
        b=WwgRQlLy/rdp3+uCB21QXIbsdmwjfx3H6VoXPJIt68twVOfN3PtuBdg4R7DSCuhdWe
         eT2/zprRuhtO9s+FYQYV2r3EYO1iVPj19QHcvjkvCc5qodwqSwtcM/boqod1hL95uNH+
         6KEbFXxj6NpWgrWEHsoFdS626q/HgcTOPPbfR/CxwpcUaUt53m87EAtfoKuEdM1Qre+Z
         +kXZS8lLPBH1X+PIJesYiOErUoLfVYv3jXKCKGWBqjYYa08ZNdA2NY1dsZhM0To0RhFS
         X06jWyoH6b3RV5Q0UUgqZiZ8w3MLUWLVT8jlkGe6MaLyg4VPs0XXk300ViN3cFIlv2gP
         6zWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=112d0Xs8rSgYB+ol4sBKoXelDAYKs2aw8MYQMbZsz4M=;
        b=Kj/TwCvf+RglXXTPlQIP5yNOJ/KqVVj2wBJiYcV6a6tRaXSYPNf5J4gvUDV7Oa1/4P
         oYsVxvxmkaFgbTzxJ3kB/8IfqHh5MAJqFxSdRjG/eHI7Z52ToBy6YLCO8SEH7HU6kfLl
         fdXwCitDEZxlQZcl1PADSJNWmyjjcbYwJr5Uu02PKyyB12X7lWUJirFUSgoqwrdvDgzl
         vkszP1OhR+0n2LtBlX3lukF9zIqEZescouW/tYMRVbZNBzjzVhVu/NeAq5W32kPNDTzF
         Udk7qgMWVCbKanbDWia7w2x8+ToI3zEl7Uh14AIdBEbXG784qv1fnZtxnB09+0fDQn6n
         WbzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XPVgj3+q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r124si22267678pgr.201.2019.04.25.17.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 17:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XPVgj3+q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B2912212F5
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:30:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556238627;
	bh=ZsIbUeLOxUI7bxZ1I5VzBXBiV9Win2BFl2iIJvXToNg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=XPVgj3+qb+Ykb0MjNHKhNcV3Yo9b7Oh8+K4gAy33Im/oRgNOCSVgtwla7/2VYGvA7
	 7XZU2rkWj1/g4+Ifz2JGp6nZfJbSva/pRSNhUX4xbErQ3YzyJ3apIdcwE6dO7TFu04
	 GHSqHZvCo/ZbCqBSb7qZRx7OySOrA0h4CSc5WPc0=
Received: by mail-wr1-f54.google.com with SMTP id c12so1852147wrt.8
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:30:26 -0700 (PDT)
X-Received: by 2002:a5d:63c7:: with SMTP id c7mr12902589wrw.199.1556238625152;
 Thu, 25 Apr 2019 17:30:25 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 25 Apr 2019 17:30:13 -0700
X-Gmail-Original-Message-ID: <CALCETrWkYYh=L1nSO7GYt0FvMhjCcEaQiM2JEi3FfkJbYJFh2g@mail.gmail.com>
Message-ID: <CALCETrWkYYh=L1nSO7GYt0FvMhjCcEaQiM2JEi3FfkJbYJFh2g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/7] x86: introduce system calls addess space isolation
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Andy Lutomirski <luto@kernel.org>, 
	Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, Jonathan Adams <jwadams@google.com>, 
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, X86 ML <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 2:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi,
>
> Address space isolation has been used to protect the kernel from the
> userspace and userspace programs from each other since the invention of the
> virtual memory.
>
> Assuming that kernel bugs and therefore vulnerabilities are inevitable it
> might be worth isolating parts of the kernel to minimize damage that these
> vulnerabilities can cause.
>
> The idea here is to allow an untrusted user access to a potentially
> vulnerable kernel in such a way that any kernel vulnerability they find to
> exploit is either prevented or the consequences confined to their isolated
> address space such that the compromise attempt has minimal impact on other
> tenants or the protected structures of the monolithic kernel.  Although we
> hope to prevent many classes of attack, the first target we're looking at
> is ROP gadget protection.
>
> These patches implement a "system call isolation (SCI)" mechanism that
> allows running system calls in an isolated address space with reduced page
> tables to prevent ROP attacks.
>
> ROP attacks involve corrupting the stack return address to repoint it to a
> segment of code you know exists in the kernel that can be used to perform
> the action you need to exploit the system.
>
> The idea behind the prevention is that if we fault in pages in the
> execution path, we can compare target address against the kernel symbol
> table.  So if we're in a function, we allow local jumps (and simply falling
> of the end of a page) but if we're jumping to a new function it must be to
> an external label in the symbol table.

That's quite an assumption.  The entry code at least uses .L labels.
Do you get that right?

As far as I can see, most of what's going on here has very little to
do with jumps and calls.  The benefit seems to come from making sure
that the RET instruction actually goes somewhere that's already been
faulted in.  Am I understanding right?

--Andy

