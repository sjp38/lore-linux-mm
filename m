Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F531C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF153204FD
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:44:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF153204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56A296B0003; Fri, 22 Mar 2019 07:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A716B0005; Fri, 22 Mar 2019 07:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40B666B0006; Fri, 22 Mar 2019 07:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E01326B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:44:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v26so822294edr.23
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:44:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Tav0MB74Nh/M3m3RiXTkRNv3a64B2p67Qw6z3my0wi4=;
        b=kx3NDWpOPjbHMEPsI/LsstO9or2QinxZcWPaf4KMMe9c2U+UBwXHtWww+7rLEO9OAp
         dvyIDHFCKRhlVl50Au0pQjYOet6gvleaAwHSlWPbL2fhezwr0z/jogxQFf+HGLrqEEBp
         QY8xkKE/tlsG7nygOeIrz8yjUh7cmlrB0Gk2+xrtsmE/qgHVl42a3M3yrAT6WdHjiYXA
         oiW+4E2skvt/jSsHTgkcrYFWLvkXSmM53VVczA6qrR9Zq51PowTT2rZzLA8lY8WvMzM4
         /2V8MhaB1++VZQvyAbRBx5HyMvpTV0+NUhMd5KJ1kkIsctoXPrczET3A5FEj688bxFLS
         YpJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUgafh7zm7A6zurvJbVjbQ8McQbgtxkLi6Jtehe6UJI4FZ1FFHo
	OfsVSJTRk+wH0vcX7QgyEtPVt/przJRuMtI8oB9gRbH42uEST9G3Xf5cHPu+/wxWylG48vzM1nr
	HVuI7UVdQvLWMGa9PWdo0YSBlJ4Ah1+E/yRRKxL+Gcrs5qTaOzH+u+fS4ApnIEHOm2A==
X-Received: by 2002:a50:a539:: with SMTP id y54mr6160729edb.154.1553255050484;
        Fri, 22 Mar 2019 04:44:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk9I/9ZWlGuhdhTDx0RZBmMoWTVGvV/JPa0SjLe0TY1tLTakTMzDHTyFhUGt7CdEJTyzz9
X-Received: by 2002:a50:a539:: with SMTP id y54mr6160688edb.154.1553255049457;
        Fri, 22 Mar 2019 04:44:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553255049; cv=none;
        d=google.com; s=arc-20160816;
        b=WNmdSX0XfiDvW0+izEZB4d2MgKfc0Q5rwBUTmRRRt+A0h9t2cZvcJBFMcar+Xylzht
         x/ZtI2mQOLR6fkQl37TwO+4kq+/DvqXVukB/YqPTYTCddeOxvO4QfKTisXoBIa26otC4
         xemtHHWgIgyWCMGM1LexVnLHzoKaGNnNMH2qnCN7P8fvzcgTXlhAYJ3YcvlkZpvhMT7R
         Oa/a2xoctjPCTlYiNk1ouI67lRMmc98rORuVYaKGnMvIajKaJsz/lb1qARAthT4xfjs3
         t4IhP1ePVadQrl59P/JQoblErWx253q42pTwcVRTf0J+UOxiZjKbdUX1vXiTwhTQnUtu
         jqKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Tav0MB74Nh/M3m3RiXTkRNv3a64B2p67Qw6z3my0wi4=;
        b=lfVq4kUlUYRQIarMUsvFCqdchcu6FRKINiSEsv++QVdsgYE8k05lIdwSAgtBAqbXgq
         VLaM3XQ9ts1BqhbHgo25Oqamk3EsfDOgK4RES7sdcBKmU5oYS8w00WMu7967dLM3I//e
         k4+2mfC3AWbax26CqPL2NKsmrJ9zrDFCvyFDjizd+4Z5ExqGg4MJ9xSDE1di5evfmBTO
         x3xtXDjg0Pr+XPeuxAcC6mQOoU9W6bGEDK3hMJUJn/J1rYZcjhUyppQfcVsJuZNgpHJ2
         /6AwslVkQB64nPSTCXGLbuNWeV9BYxoHX4JTQ0TzMmLKtMkoCuOo8YhjlmAi8ETEUL1w
         sG8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id jp19si311538ejb.116.2019.03.22.04.44.08
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 04:44:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 171FE374;
	Fri, 22 Mar 2019 04:44:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 588F73F575;
	Fri, 22 Mar 2019 04:44:00 -0700 (PDT)
Date: Fri, 22 Mar 2019 11:43:57 +0000
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
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
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
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to
 memory syscalls
Message-ID: <20190322114357.GC13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:18PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: madvise, mbind, get_mempolicy, mincore, mlock, mlock2, brk,
> mmap_pgoff, old_mmap, munmap, remap_file_pages, mprotect, pkey_mprotect,
> mremap, msync and shmdt.
> 
> This is done by untagging pointers passed to these syscalls in the
> prologues of their handlers.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  ipc/shm.c      | 2 ++
>  mm/madvise.c   | 2 ++
>  mm/mempolicy.c | 5 +++++
>  mm/migrate.c   | 1 +
>  mm/mincore.c   | 2 ++
>  mm/mlock.c     | 5 +++++
>  mm/mmap.c      | 7 +++++++
>  mm/mprotect.c  | 1 +
>  mm/mremap.c    | 2 ++
>  mm/msync.c     | 2 ++
>  10 files changed, 29 insertions(+)

I wonder whether it's better to keep these as wrappers in the arm64
code.

-- 
Catalin

