Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7660C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 13:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DD7A2087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 13:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD7A2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE8F88E0003; Wed, 13 Mar 2019 09:47:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E97588E0001; Wed, 13 Mar 2019 09:47:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D87948E0003; Wed, 13 Mar 2019 09:47:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB3B68E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:47:14 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d8so1552941qkk.17
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 06:47:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=T9hhGiqFkQOyj2HsXpZqb68aTtiFInjQWkWhoHrfSTE=;
        b=pv5AIRWUcCl5nthJnrYMFQgmwiaKFwupJOe1z7ftudIb56t4+07gl4fE3g3PGExbOf
         JF6Dl7PVvD3KLBgsBmUFrOldwn8NaLMw+3UWJMe5iYZkRGgv/0bQojYM5p+OyGoS+ahm
         v99ajC71adbZhmyiyUs3oWJNTQQiTQ6irfYw7kkXj4QJcKbbwEfxAUY7Yvo9XKHiG151
         pwlcnsc4WOo2l0ZLyNDB/Ec6QzG7o3eDLsbfiupdPe8dVjFxln2kHp1TVIWcMSBUetK6
         P1OQFmlnl6MiCH3Qwd8DkLE3oGlAkWqfQENTzyeki8e7g1uh2RA+RqDsLDkYMkfoCfNw
         f96A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXespK1cxbxwu3PnfXnmQzUBpoeVRZUwBLbwOjOZYlxJWsGmQUS
	Hg7esddTdznJuLYw+kLjQM70xXZqzYtJGBG3/So9F2JxqO5yFKT/XFqyif/IMF1kTv9ejpElsIR
	irIH2xTiH92k9G7ztA5ITlppRSSLdrU0ZxYd016Nl6XTE55NFZ13nQ98EbYrjRrW5Jwd4MyYMft
	yTWbNYlgqRj+XV1awUv+VJDAsO1SNHT5hgOoO8Bdm+ZQ9aN48IUuPMAMR7PSOGa+l7dXb8ZPF7O
	906VGVlGbdnrF/Y/HJnyUSCnx77BtmUJsq95GN1rE1nvK07nfIa1RMoe1IQOSUkbvlTZNDZ28Qw
	SuDYH31eqIZrrWX90fkU/vjlJsB9XWRSpSUcKBoecJYSfxIWsJdpNJSHxUXCqhnFV93UdJLQKA=
	=
X-Received: by 2002:a0c:e58f:: with SMTP id t15mr691205qvm.170.1552484834536;
        Wed, 13 Mar 2019 06:47:14 -0700 (PDT)
X-Received: by 2002:a0c:e58f:: with SMTP id t15mr691134qvm.170.1552484833552;
        Wed, 13 Mar 2019 06:47:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552484833; cv=none;
        d=google.com; s=arc-20160816;
        b=vtCF7iKnHlVO3dkAezjyulqIRR0meA0D9jXn+ovQ/ou+3E+bNCncmtEU8TGm1tBZOn
         7lxpAqSz9CF/LrXp9y+6uWWnteNpeT31cUVNtTi3rmPwPpFRhWbZ9JcaCKhJnPuHOzOM
         3eEwjkyJm4YB2XEQSALOE4gxAhYeAVnqmi3uILaI5TZ3YhJuK9/sXNez/5vgIdK2Zgmd
         NsKoWSLm58cMZshjY/p0n/GL7Bo9pIOYl6DpPLsnG4GV81BNWTJeqZKfnHtpdmCk/N7T
         UZQtOXC8qJcRMK3rkR+2bC8gsDWNZIsgqlyd8arE/NT2BfDcQv/zlysuectO+cmegU0D
         n8zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=T9hhGiqFkQOyj2HsXpZqb68aTtiFInjQWkWhoHrfSTE=;
        b=s8UGDfLJ4MY6QWIF+PTZU4FFi2d1Bc/MRhpefYx6bPVfo4pMQb6qE4gh7+qoqjPgvH
         Pszf/TyoySiIR5wy6Bol3McoLUyB8isF3kW2fWho7WrXDv+dPI8Ql2WiuxVxFVWa2aNX
         /bSKf9aRg6En0IoYqd3T7C234/HV21KUv33+rWTK4nALtDp0R/SWWAL//svP7PvsZMf1
         RJuGetemRjvI/jL7nLm73D/JBxKoevRQ8eINBKhrCMVyMtH/WfgAGO27mcPj1prxKmtd
         9fz0DWPKUQhBUbiSgGCogoGH9GgDlzlcP7xMR2ZzcuchXG0tsz/omvP1sc4AuJ5CVBUm
         gPNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u16sor13625768qvn.9.2019.03.13.06.47.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 06:47:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqzDz9nXPvhIIABdz4si/3eHnXmxwwi1bNgLVFzVGNvjIBFKeOcRRRFharl5kiWI4O48Lgd+6ldPwSqyMGehKL4=
X-Received: by 2002:a0c:b05a:: with SMTP id l26mr34139845qvc.40.1552484833092;
 Wed, 13 Mar 2019 06:47:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190310183051.87303-1-cai@lca.pw> <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com> <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com> <20190313091844.GA24390@hirez.programming.kicks-ass.net>
In-Reply-To: <20190313091844.GA24390@hirez.programming.kicks-ass.net>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 13 Mar 2019 14:46:55 +0100
Message-ID: <CAK8P3a3_2O7KBKTSD-QC5tcpohy8bkVVHsdAJnanTU1B+H12-w@mail.gmail.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Qian Cai <cai@lca.pw>, Jason Gunthorpe <jgg@mellanox.com>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 10:19 AM Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Mar 11, 2019 at 03:20:04PM +0100, Arnd Bergmann wrote:
> > On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
> >
> > At least the atomic_long part we discussed there has been resolved now
> > as part of commit b5d47ef9ea5c ("locking/atomics: Switch to generated
> > atomic-long").
> >
> > Adding Mark Rutland to Cc, maybe he has some ideas of how to use
> > the infrastructure he added to use consistent types for atomic64()
> > on the remaining 64-bit architectures.
>
> A quick count shows there's only 5 definitions of atomic64_t in the
> tree, it would be trivial to align them on type.
>
> $ git grep "} atomic64_t"
> arch/arc/include/asm/atomic.h:} atomic64_t;
> arch/arm/include/asm/atomic.h:} atomic64_t;
> arch/x86/include/asm/atomic64_32.h:} atomic64_t;
> include/asm-generic/atomic64.h:} atomic64_t;
> include/linux/types.h:} atomic64_t;

Right, that would make sense as well.

> Note that the one used in _most_ cases, is the one from linux/types.h,
> and that is using 'long'. The others, all typically on ILP32 platforms,
> obviously must use long long.
>
> I have no objection to changing the types.h one to long long or all of
> them to s64. It really shouldn't matter at all.

I thiunk it needs an '__attribute__((aligned(8)))' annotation at least on
x86-32, but it should be harmless to do that everywhere. The
32-bit architectures of course already use a 'long long' base type
(unsigned long long on x86 and arc), but we'd still need to
change all the 64-bit architectures to consistently use s64
in their implementation. This would be the majority of the work, e.g.

arch/powerpc/include/asm/atomic.h:
static __inline__ void atomic64_##op(long a, atomic64_t *v)             \

arch/riscv/include/asm/atomic.h
static __always_inline                                                  \
c_type atomic##prefix##_fetch_##op(c_type i, atomic##prefix##_t *v)     \

arch/sparc/include/asm/atomic_64.h:
long atomic64_##op##_return(long, atomic64_t *);

arch/s390/include/asm/atomic.h:
static inline void atomic64_##op(long i, atomic64_t *v)                 \

arch/mips/include/asm/atomic.h:
static __inline__ void atomic64_##op(long i, atomic64_t * v)                  \

arch/ia64/include/asm/atomic.h:
static __inline__ long                                                  \
ia64_atomic64_##op (__s64 i, atomic64_t *v)                             \

arch/alpha/include/asm/atomic.h:
static __inline__ void atomic64_##op(long i, atomic64_t * v)            \

arch/parisc/include/asm/atomic.h:
static __inline__ s64 atomic64_##op##_return(s64 i, atomic64_t *v)      \

The problem is not that any of those would be hard to change,
it's more that there are so many functions across 10 architectures,
and everything has some subtle differences somewhere.

It would be tempting to use scripts/atomic/* to generate more of
the code in a consistent way, but that is likely to be even more
work and more error-prone at the start.

      Arnd

