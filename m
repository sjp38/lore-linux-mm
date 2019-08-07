Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC079C32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 10:00:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8462D21E6A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 10:00:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="tCgJHesT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8462D21E6A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCF006B0003; Wed,  7 Aug 2019 06:00:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C58736B0006; Wed,  7 Aug 2019 06:00:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD2206B0007; Wed,  7 Aug 2019 06:00:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 716686B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 06:00:17 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so51058835pld.1
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 03:00:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZzlW9YyeiJ854Q1Ko1IPtbBbq0BYDBiTFOQHxFAcEc0=;
        b=VKEEdt4zR+4Hulf400s/1ffA1cThcrKSxYNME18us15Eg8QjhOVARDhjMJOy108O4g
         h8R0GIoQtMiITow1opjQZkvgIml8lnijZhRDwE/AgjMljCWEz4YTDEGwpTVJ7q0UmxAb
         cEJz5FPhUbs9nSHA8c+Jq5FPQnLl4Eb/SD/0f5yX4a371tlainNhmMPuOkPDZjs7BldW
         CylD3vNl3miwFbSDRmo3sdcgFhatUPqHEva+ieOpehe8Q1o77RLpzajsVwwuDm7xQ6iU
         JxzKfRmzLgxZbrbWU3DWWbBRqneEmbRJzoOSOiS+R5JkdrtXXusStoYPSR//ijdgByCr
         IAtA==
X-Gm-Message-State: APjAAAU9bwu7f0DmMHN9wlvGQhpbHb2s/MncHrZHSoOuivw0OlDtJkdZ
	sqF2JC+ItLpLg+DZ6czdXw2q5Uja3cOZ6JCATUXcU1w4hppZL5ryWs4jdvpLJx9iMFiln+C/wjk
	NgpZponNKakEVOX+Xd2c/kdrYjuXELgZZFvcyJuIQ/cnjlhO/4nwcb+sj+h/o9ghKVg==
X-Received: by 2002:a63:8a49:: with SMTP id y70mr7303827pgd.271.1565172016936;
        Wed, 07 Aug 2019 03:00:16 -0700 (PDT)
X-Received: by 2002:a63:8a49:: with SMTP id y70mr7303741pgd.271.1565172015900;
        Wed, 07 Aug 2019 03:00:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565172015; cv=none;
        d=google.com; s=arc-20160816;
        b=djfsjPSbyX/vR1lpcGPOeK9YLQXuiKvNphSiX9CM1ASpatRH1IdsgcpuPPDvvyu/cp
         tfXcFo/AZl4zd+1NK4pwuY+zu9ZQEOgwQc3mgMH2mqa0EOVqefMMpDUgvX9KcaPQw9ac
         XGJ5TZCDzitC4mVYs88P7bwM7t+6LvplQOAuJkUYH/syHa965Sxc6ZrRQj30eCAWIRaw
         ZvPPScEc56QL4anrIA9w6qiunKOM7R01avruF/2LvQxkL5J2jqN6L4ylEW06bdFRz44v
         XQU9eiUWmwjRSnbx90uFwg4ZZGOoypNaRc+XVfXkq5MpTqomTCmeglc/fgBhlz5MSoVv
         JWDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZzlW9YyeiJ854Q1Ko1IPtbBbq0BYDBiTFOQHxFAcEc0=;
        b=Abp3xwKRa4SD9uX1GM21PSwjoK7dxrOVq/eTIGnO+plQmMaTVxB5SvjbJKf215ueGX
         ZkHWe3JNlYXKHlqLhVxEckEOfxXkGH7MotKqEAyXWkdO4udXvYDji2cbK54iC2/ZIZkI
         ijJVYRhC3zYQmAztFgpy22wU/pyUZI5J//HWf+1IdqB8MIM+0TmWCIKSeDkIRZnOM5xu
         pkOs7AFy5/1H/OM7jsEU10XJK3RyfcdbhRVwKX/l7qW5zP3C2U5iPdouNXolTgrmHgph
         QYBzJEYgbFxLTzYk+zoZiN50y1W8Jhxmwehs30+/3Xq4HpW8J1Rc5Cod6GANdnMcdGaZ
         RUOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=tCgJHesT;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11sor70718883pfc.49.2019.08.07.03.00.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 03:00:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=tCgJHesT;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZzlW9YyeiJ854Q1Ko1IPtbBbq0BYDBiTFOQHxFAcEc0=;
        b=tCgJHesT9hyuTLNhA2JU2/UNk19RK2nU5AFtCBJaYk5S3w1NDvpmaFeth5Yo8wYH0s
         oM4Lnuq7N9b9hZ/RVsWSEyFtN0JZddKU9+yGb3onrTbH8MixdAzzdFWXDrrSZxkzHWDG
         kUybN6h9P7J8OPDKxwZ6UTFwzfLKIdRbmfvNc=
X-Google-Smtp-Source: APXvYqy9F4k99hNGDmUxs4p0Ff8mjnfF/NFd08nAV9/aNP72bhh+a9yeZ5zU0WZFHIFPpVKE8BbX4A==
X-Received: by 2002:aa7:9117:: with SMTP id 23mr8530297pfh.206.1565172015496;
        Wed, 07 Aug 2019 03:00:15 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id b136sm120273213pfb.73.2019.08.07.03.00.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 03:00:14 -0700 (PDT)
Date: Wed, 7 Aug 2019 06:00:13 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-ID: <20190807100013.GC169551@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190806151921.edec128271caccb5214fc1bd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806151921.edec128271caccb5214fc1bd@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 03:19:21PM -0700, Andrew Morton wrote:
> (cc Brendan's other email address, hoping for review input ;))

;)

> On Mon,  5 Aug 2019 13:04:47 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > The page_idle tracking feature currently requires looking up the pagemap
> > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > Looking up PFN from pagemap in Android devices is not supported by
> > unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> > 
> > This patch adds support to directly interact with page_idle tracking at
> > the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> > the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> > looking up PFN through pagemap is not needed since the interface uses
> > virtual frame numbers, and at the same time also does not require
> > SYS_ADMIN.
> > 
> > In Android, we are using this for the heap profiler (heapprofd) which
> > profiles and pin points code paths which allocates and leaves memory
> > idle for long periods of time. This method solves the security issue
> > with userspace learning the PFN, and while at it is also shown to yield
> > better results than the pagemap lookup, the theory being that the window
> > where the address space can change is reduced by eliminating the
> > intermediate pagemap look up stage. In virtual address indexing, the
> > process's mmap_sem is held for the duration of the access.
> 
> Quite a lot of changes to the page_idle code.  Has this all been
> runtime tested on architectures where
> CONFIG_HAVE_ARCH_PTE_SWP_PGIDLE=n?  That could be x86 with a little
> Kconfig fiddle-for-testing-purposes.

I will do this Kconfig fiddle test with CONFIG_HAVE_ARCH_PTE_SWP_PGIDLE=n and test
the patch as well.

In previous series, this flag was not there (which should have been
equivalent to the above test), and things are working fine.

> > 8 files changed, 376 insertions(+), 45 deletions(-)
> 
> Quite a lot of new code unconditionally added to major architectures. 
> Are we confident that everyone will want this feature?

I did not follow, could you clarify more? All of this diff stat is not to
architecture code:

 arch/Kconfig                  |   3 ++
 fs/proc/base.c                |   3 ++
 fs/proc/internal.h            |   1 +
 fs/proc/task_mmu.c            |  43 +++++++++++++++++++++
 include/asm-generic/pgtable.h |   6 +++
 include/linux/page_idle.h     |   4 ++
 mm/page_idle.c                | 359 +++++++++++++++++++++++++++++..
 mm/rmap.c                     |   2 +
 8 files changed, 376 insertions(+), 45 deletions(-)

The arcitecture change is in a later patch, and is not that many lines.

Also, I am planning to split the swap functionality of the patch into a
separate one for easier review.

> > +static int proc_page_idle_open(struct inode *inode, struct file *file)
> > +{
> > +	struct mm_struct *mm;
> > +
> > +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> > +	if (IS_ERR(mm))
> > +		return PTR_ERR(mm);
> > +	file->private_data = mm;
> > +	return 0;
> > +}
> > +
> > +static int proc_page_idle_release(struct inode *inode, struct file *file)
> > +{
> > +	struct mm_struct *mm = file->private_data;
> > +
> > +	if (mm)
> 
> I suspect the test isn't needed?  proc_page_idle_release) won't be
> called if proc_page_idle_open() failed?

Yes you are right, will remove the test.

thanks,

 - Joel

