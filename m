Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A799C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A23962077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:50:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A23962077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B3EF6B0006; Fri, 26 Apr 2019 10:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 162246B000A; Fri, 26 Apr 2019 10:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02BE96B000C; Fri, 26 Apr 2019 10:50:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A28AB6B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:50:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b22so599638edw.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VMoU3VnhEPr8EnNHxaesfpMBJGBd7cYvGrJMkSUIGcQ=;
        b=sYt3mpmTmADsGf9OlIK54Jug9Uk1uslEteyceiSe8s/xvBfvdZZcqRx/4T8VJYo3ay
         ylNOCwtEkgzIRd3p+N3waZEHtMxlRN76lChwhO7XgbLRR/D605NezkYbyOggu3/GeIwg
         KvlrOOOVzNFy3Cld6+BKbtrUHUHTOgtdWNh7Kk+L4Yg+DQLlTyccacaJGopcxkZpV6Am
         kB0CRUOZgHmka9nfeB/hGJbP0Kebcs5vHsU9cFGHR0fHi9yYR10lgKpybtLG0ZlbaD7Y
         N83p1DyAZk7IGBXmUoYjRUORiC4Esf84MdUfnt/rgw0qlvPJ7mG8rNR+egm0cXwk8zLz
         L8Qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWYQmcUD4bx6u71vwo8IsePtLO6Oedz+ADci13iY1dqgSSryK70
	vqG4dVThyC1ZR2rRKGU1XlHj5JpHZU03DfBzHnkzazw2FCZOO9n+NDZfsfUGFL5xznX0b83Axjd
	BS+1Y1g6zC/T5iylyRE9WHaU8LZ471KsAXsUiUSSEa/yeAbsItTO7BGfbYyakZGXSrw==
X-Received: by 2002:a50:98c2:: with SMTP id j60mr17676009edb.128.1556290238196;
        Fri, 26 Apr 2019 07:50:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaWMGao2Du+cP/S9fMVsW7Jd3Xn7qQDchddww3UGnIIvlVVRSQMEock3mGZhrJXV8arUWp
X-Received: by 2002:a50:98c2:: with SMTP id j60mr17675965edb.128.1556290237358;
        Fri, 26 Apr 2019 07:50:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556290237; cv=none;
        d=google.com; s=arc-20160816;
        b=LcIAtWM2CFKFBoABTmgTObH8nwKhieYXd9pTTeU5Sg4FuObL3rvaEfCnygR21Z4OXJ
         Wv6LriUGV7k+Sx9YvNnpCtQwFEfNgo4/an3uNDBKlCj7IXET60O/oqQa0kOhsG8SfaV8
         aSIlXa2Q09MZuNJv1QfDbZQMEpQrMLf6TVPxi+m1VGsZKYqN9E/65P+uRWfVtPNnRPIQ
         t67CGtQiz6wv1l3Jo3taZa39C4kS1GpHUEC4YNE3lDPp4uIzuAfAehPrCWVtZHrBiQ4/
         JiTpY+/wzY2DdL7EcgjQ1PrkR52e2pc0d6hIV7ij5bJLDWuGeeffuZ0lwZa8mQB7oJNF
         QQIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VMoU3VnhEPr8EnNHxaesfpMBJGBd7cYvGrJMkSUIGcQ=;
        b=Iiq4p1xBx6fcIx/R4Jv1mF5bB19E6k6ntHuR5LB24mksacsD8vY+OrIOGUy+uQf+IH
         pEi6a0F3e1PFyWCB8aIqdh8EC8LYBBTtIzg9CJhQXQnVXH5AJt1hYuMDE3wqaLOVy1j/
         pJzd2Yv/ZYEGxlXLDUKowBP3o4usofngCnxf5XX3K0bZl6eWsH6Uoe24CnK43za+kmdZ
         dFVnfL8io2q1B/l5RK8vYQFDezzKv0LJyANU+ldIv3EiIyHfxthckPILKFEf8Ih7ksYc
         dXQRt4XZn1SrD3Up1DgCGV+oy1j6MmAPmAfIBC8Sd/l1kHQLYza3V0+O6gvIgHFqnJT8
         2rjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l20si4772378ejr.239.2019.04.26.07.50.36
        for <linux-mm@kvack.org>;
        Fri, 26 Apr 2019 07:50:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E922A80D;
	Fri, 26 Apr 2019 07:50:35 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D44B83F5C1;
	Fri, 26 Apr 2019 07:50:27 -0700 (PDT)
Date: Fri, 26 Apr 2019 15:50:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
	kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in
 prctl_set_mm*
Message-ID: <20190426145024.GC54863@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
 <20190322154136.GP13384@arrakis.emea.arm.com>
 <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 06:44:34PM +0200, Andrey Konovalov wrote:
> On Fri, Mar 22, 2019 at 4:41 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
> > > @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
> > >       if (opt == PR_SET_MM_AUXV)
> > >               return prctl_set_auxv(mm, addr, arg4);
> > >
> > > -     if (addr >= TASK_SIZE || addr < mmap_min_addr)
> > > +     if (untagged_addr(addr) >= TASK_SIZE ||
> > > +                     untagged_addr(addr) < mmap_min_addr)
> > >               return -EINVAL;
> > >
> > >       error = -EINVAL;
> > >
> > >       down_write(&mm->mmap_sem);
> > > -     vma = find_vma(mm, addr);
> > > +     vma = find_vma(mm, untagged_addr(addr));
> > >
> > >       prctl_map.start_code    = mm->start_code;
> > >       prctl_map.end_code      = mm->end_code;
> >
> > Does this mean that we are left with tagged addresses for the
> > mm->start_code etc. values? I really don't think we should allow this,
> > I'm not sure what the implications are in other parts of the kernel.
> >
> > Arguably, these are not even pointer values but some address ranges. I
> > know we decided to relax this notion for mmap/mprotect/madvise() since
> > the user function prototypes take pointer as arguments but it feels like
> > we are overdoing it here (struct prctl_mm_map doesn't even have
> > pointers).
> >
> > What is the use-case for allowing tagged addresses here? Can user space
> > handle untagging?
> 
> I don't know any use cases for this. I did it because it seems to be
> covered by the relaxed ABI. I'm not entirely sure what to do here,
> should I just drop this patch?

If we allow tagged addresses to be passed here, we'd have to untag them
before they end up in the mm->start_code etc. members.

I know we are trying to relax the ABI here w.r.t. address ranges but
mostly because we couldn't figure out a way to document unambiguously
the difference between a user pointer that may be dereferenced by the
kernel (tags allowed) and an address typically used for managing the
address space layout. Suggestions welcomed.

I'd say just drop this patch and capture it in the ABI document.

-- 
Catalin

