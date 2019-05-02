Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20B7AC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 11:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D33A320873
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 11:35:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ocallahan-org.20150623.gappssmtp.com header.i=@ocallahan-org.20150623.gappssmtp.com header.b="0H9qZOLd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D33A320873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ocallahan.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7291C6B0005; Thu,  2 May 2019 07:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DA376B0006; Thu,  2 May 2019 07:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8966B0007; Thu,  2 May 2019 07:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE9E26B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 07:35:48 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c10so303684ljj.20
        for <linux-mm@kvack.org>; Thu, 02 May 2019 04:35:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:reply-to:from:date:message-id:subject:to:cc;
        bh=j++TiTibQtSVl9YAF3/oqacqYf/6ZNJGN6BZGgzoCww=;
        b=JTjW0UhyDmJ7q1VNw/VGgdTYo78WaaHG51maGUooBM7uhrfYFazEyutHs0NMWHOHjn
         qI3L5WWSUl9f7r+cheotbpEkw/b1ai8D5NNvokYgUGf1WPkELuprtanq8r5PjfqIw/KB
         PkVpalevrY4wlIPYjY0z8tHR+F0gCFKkzpfiNxzHf01MAlbs8LRpLXpuLkOirUzW3wQS
         WYrr3OgKkfoVASov/GYeHCvuJ+027/NdBZynmc4WuxLDV3H6XhgQWtL8sej8NpkG2QgL
         6P+H6Ad9Chid9X/8bKS9sAm1M7vASbZfHVXD7DzpEcK5YR7NKLIcAY0AdJf522TbhXga
         m23w==
X-Gm-Message-State: APjAAAUxE9UsK8EQqwbhbHAx+UK2ysiS7uofTFutIDoM+EDrjoYLC5KW
	VE7uIoOLFFKY4CFm9i/lAlm8E6fn6fcP3/wFK7hooiX4dr6rCP/IilgL6r8wXVnryGN9akcHMED
	640fSpGkItu20hLEvOZQhPS/IfSlPLt3mPoDbKtgckwNf6BOvaB5wVdDs8l03lPs=
X-Received: by 2002:a2e:858f:: with SMTP id b15mr1653326lji.144.1556796948243;
        Thu, 02 May 2019 04:35:48 -0700 (PDT)
X-Received: by 2002:a2e:858f:: with SMTP id b15mr1653267lji.144.1556796947118;
        Thu, 02 May 2019 04:35:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556796947; cv=none;
        d=google.com; s=arc-20160816;
        b=kkSaR+Qn2mjFZs5O+4Z3N25fTR+KfiVpjHKqYWaB1G4lukRiKme7eUgXEOeaue88Ce
         N/F0nXV7+v6nmzvDPWd8Osg4d+NJFiOTsMMLdRYXR+92cscednQjGNy8rsK9WC/bgY8O
         SGk4pugli68beKzhm7h7BX398oO/Qhhik49FcO37ZxoVF+UZ3E+1zt/XXeECB+4q6Kc+
         CY2Q+3g/+s/ex6Kova8FbZ0okcyqcN1etLXH+09Hxo2BBL5UoLKBQ2Ot4L9v+uBy5JCj
         2Q8bOTG70zXiupgYnwmOl2fgpnP3+mfuprHg9XAsut+oE4v0eZHT4R5D/ZYkLo2em46P
         HB9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:reply-to:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j++TiTibQtSVl9YAF3/oqacqYf/6ZNJGN6BZGgzoCww=;
        b=PMstet4/x1fpIZiQJvzFyPVxHW+eyEsYk3yWZXp6n8SuUXbAtfTfhrUrbMieTenCyP
         piw1HdrnYtg5HeX8PPuzO+1PNmNMa3X+/Qo8FdJzHEZXt1lp8sR7WJRXHZ6R1vJWYMxv
         iE0AZ+wUPvxEkZ4W32pRqdGghfjZ9COJBGZ23NKCT6X+zTkRjWliMASZlNB2iESarn0X
         wX+98Yyad/eitZVnD/BNM7Xly4fmbgcU7oR9tHGTS0IVbGIo3WZImMZeColW5YOcANX+
         H30oNR8d1Xz/1SCOu/lkUFF9fWbCx2Wc7yGVjQ6YYDPIjLKePkVwsyZ4+ij439boVin7
         6+eA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ocallahan-org.20150623.gappssmtp.com header.s=20150623 header.b=0H9qZOLd;
       spf=pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rocallahan@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y79sor1097432lfa.37.2019.05.02.04.35.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 04:35:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ocallahan-org.20150623.gappssmtp.com header.s=20150623 header.b=0H9qZOLd;
       spf=pass (google.com: domain of rocallahan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rocallahan@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ocallahan-org.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc;
        bh=j++TiTibQtSVl9YAF3/oqacqYf/6ZNJGN6BZGgzoCww=;
        b=0H9qZOLdO21+HdB9rbdwA4TdkIwgdYm+/OeqS3IwlILWryk4o/i6fMK92cnzjlf5d+
         0OAwzQOkeD28c7YH6eco8BUodMbodQLIvMA9K/+hCj9FFBanIhHsDTxWIaOFko8EKel3
         zSFRM58Enni/0sfu1lojb+Rh0349rNJQwgnCVUMe353c38F3CMEFovePsjxDPeRfeIx/
         utSiV3/LMYR2Dqu3XV4xeErBtRaiDgc5Sv6BSJuLmXC6Es8cPhdkIirs2LVr0GMugKnW
         NBPJtLw2jgN5szGLBemMxX5/jwWj73+3M2fiJlRQZpw9YccJDve++TtuuJsE8ML9PRrE
         NoqA==
X-Google-Smtp-Source: APXvYqzxeUby9yFoLptAe0k7AKsIZUdYS+XMP7+LA0QnUSMXo1qvkRNSzH4R87VA/WRCVh9nvlZswwxjI6mg8WhdsxI=
X-Received: by 2002:ac2:5a47:: with SMTP id r7mr1883560lfn.116.1556796946527;
 Thu, 02 May 2019 04:35:46 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com> <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com> <20190427104615.GA55518@gmail.com>
In-Reply-To: <20190427104615.GA55518@gmail.com>
Reply-To: robert@ocallahan.org
From: "Robert O'Callahan" <robert@ocallahan.org>
Date: Thu, 2 May 2019 23:35:35 +1200
Message-ID: <CAOp6jLa1Rs2xrhJ2wpWoFbJGHyB99OX9doQZc+dNqOSUMgURsw@mail.gmail.com>
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

On Sat, Apr 27, 2019 at 10:46 PM Ingo Molnar <mingo@kernel.org> wrote:
>  - A C language runtime that is a subset of current C syntax and
>    semantics used in the kernel, and which doesn't allow access outside
>    of existing objects and thus creates a strictly enforced separation
>    between memory used for data, and memory used for code and control
>    flow.
>
>  - This would involve, at minimum:
>
>     - tracking every type and object and its inherent length and valid
>       access patterns, and never losing track of its type.
>
>     - being a lot more organized about initialization, i.e. no
>       uninitialized variables/fields.
>
>     - being a lot more strict about type conversions and pointers in
>       general.
>
>     - ... and a metric ton of other details.

Several research groups have tried to do this, and it is very
difficult to do. In particular this was almost exactly the goal of
C-Cured [1]. Much more recently, there's Microsoft's CheckedC [2] [3],
which is less ambitious. Check the references of the latter for lots
of relevant work. If anyone really pursues this they should talk
directly to researchers who've worked on this, e.g. George Necula; you
need to know what *didn't* work well, which is hard to glean from
papers. (Academic publishing is broken that way.)

One problem with adopting "safe C" or Rust in the kernel is that most
of your security mitigations (e.g. KASLR, CFI, other randomizations)
probably need to remain in place as long as there is a significant
amount of C in the kernel, which means the benefits from eliminating
them will be realized very far in the future, if ever, which makes the
whole exercise harder to justify.

Having said that, I think there's a good case to be made for writing
kernel code in Rust, e.g. sketchy drivers. The classes of bugs
prevented in Rust are significantly broader than your usual safe-C
dialect (e.g. data races).

[1] https://web.eecs.umich.edu/~weimerw/p/p477-necula.pdf
[2] https://www.microsoft.com/en-us/research/uploads/prod/2019/05/checkedc-post2019.pdf
[3] https://github.com/Microsoft/checkedc

Rob
-- 
Su ot deraeppa sah dna Rehtaf eht htiw saw hcihw, efil lanrete eht uoy
ot mialcorp ew dna, ti ot yfitset dna ti nees evah ew; deraeppa efil
eht. Efil fo Drow eht gninrecnoc mialcorp ew siht - dehcuot evah sdnah
ruo dna ta dekool evah ew hcihw, seye ruo htiw nees evah ew hcihw,
draeh evah ew hcihw, gninnigeb eht morf saw hcihw taht.

