Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B117BC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:45:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 686D7217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:45:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="SKjwZ75o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 686D7217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 103346B0006; Wed,  7 Aug 2019 16:45:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0D06B0007; Wed,  7 Aug 2019 16:45:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E93C56B0008; Wed,  7 Aug 2019 16:45:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD6726B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:45:33 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s21so54027504plr.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:45:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nVq2Lrz4oly1cbME+ru7uC/EUuUzNyfifYdkSD+WXws=;
        b=fR38GSc5m9NvGkuVm26pjaGaqQ1UU9KYjdHr2i7vapcTYsIX1o87ZuEBne8f0j4092
         ikl/Iq68BoNlFl9ESznTDdfb6oRc95U17/RkBYViyaUhfqQL7ancJtcbFVQg8HDvU9F0
         aMTCh1i2TLLbsNzdDCidVRLloy+IHBIz9sHCsy4YBo7OBHEsKoM16WJ1o9kbOegHPtb0
         Qk3hkip/qFO/VHrJ0WvBxApd2xxtDNT9dPpEBme1W2UVjaKwSe4C/0MBL53hc4jbQqsk
         sqQtjgj/unn92ixVuUK06NNrQhQTlL/39U/LSU3xHn87wziERZInjjTlxOEQZi5vKDoQ
         I7RA==
X-Gm-Message-State: APjAAAU/Dpe+HnFvjl5M7acIaI6J+I6ealZ116ciUNQBoQdOEFAMbEo1
	EXao+RZN4iADSm3lqwfzQz/TPaIfeYJld3Gsn4Oof55mXuC3BrkEJiUuT7cE3R2UAWNK81TWpNn
	5BHO/2gE7AY/Vx6gl8pea7lqss6rzKXbidwYkX8M0kmFpjwYc+GDExQPsRfJX40YjqA==
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr10177357pll.129.1565210733373;
        Wed, 07 Aug 2019 13:45:33 -0700 (PDT)
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr10177310pll.129.1565210732721;
        Wed, 07 Aug 2019 13:45:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565210732; cv=none;
        d=google.com; s=arc-20160816;
        b=W+ikDzFW4AZE+lL6srUC1Ujgu8dUSB8vsrFmidCbp4cphBC6HD9IlCrREJAqPh6We5
         uYiTfCLYcUOjt8tyqOOwlxVIF9JZ5Q8zISlgSY6FLMUYgCEOVeVga7qKwT5sFYb+5VQr
         I6PeRNe5x+DT2o+lC/Rve+nHFSF64kXtW6NA9dJ6lwFGG4nMyAISMoxpyt/mTcK2Rdrl
         sIGUtXqA9j9s6U5rHi142h9TtX+VSWUzbAFQ7+rbp7uU9rpFGyEW/J+rxObok+d1XLEv
         OvdJ5+Xvm0KPT0GXrt+45ramGs6Gjg3oVsAPaQ6Fcg7AiffMn3p/YB3gTqP3H6tEUD5l
         jDNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nVq2Lrz4oly1cbME+ru7uC/EUuUzNyfifYdkSD+WXws=;
        b=pnsFSR224nrLyEYCEJV+gTCuap4cjBDHKUFqxc4LKw/MEN13yMjzsoikeryJbkpMPs
         hXCL5V+9PM857lbDftPxcuJLs0SapC300/rgwkxuTr22wmtKVLWYiC5gz5m0XWRlApmc
         CJgebA3nGZ177Y10ZPg5Aj76ixh2fDi1vLhKyPFCB8Q09B3uTBeJS2Pq1o3WpWNvTAH6
         42Y5o0kFy4B69KEO7ZOTC1uEnmMgz6V4mGRjEa9NCb+6zlNW2X3fuA2/TcEB9ghTumEF
         nMogWl+B75E8plxSZUU/83vhFUleoMUxOiWBMFZS90AK3yfpKqvc7JKGHmRWcOxAAQF/
         t8JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=SKjwZ75o;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor108459366plt.64.2019.08.07.13.45.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 13:45:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=SKjwZ75o;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nVq2Lrz4oly1cbME+ru7uC/EUuUzNyfifYdkSD+WXws=;
        b=SKjwZ75o/bjl3P6himFnL+2MJNzMb2KlU9PecY9gL2OvoO+kAS5KzKleoxU5N6Eozn
         KPw8Qn8ix5JOtTRWXYGTvhdvMcOzAtYMnblQFIQJIJh/bMOFzKoN5j4jAbdrYEbb6aWF
         i4sTmbSnKu/H2O6vxlszhwMU0BMjebOmFC5TU=
X-Google-Smtp-Source: APXvYqyVsQ2rxzfkbsU4s/td7a6F6w6wqVCgyV/YFH3HkbntL96f95eC7uJQ7+msGgxczb30VirUZA==
X-Received: by 2002:a17:902:145:: with SMTP id 63mr10208710plb.55.1565210732270;
        Wed, 07 Aug 2019 13:45:32 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id s22sm99446893pfh.107.2019.08.07.13.45.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 13:45:31 -0700 (PDT)
Date: Wed, 7 Aug 2019 16:45:30 -0400
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
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190807204530.GB90900@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > In Android, we are using this for the heap profiler (heapprofd) which
> > profiles and pin points code paths which allocates and leaves memory
> > idle for long periods of time. This method solves the security issue
> > with userspace learning the PFN, and while at it is also shown to yield
> > better results than the pagemap lookup, the theory being that the window
> > where the address space can change is reduced by eliminating the
> > intermediate pagemap look up stage. In virtual address indexing, the
> > process's mmap_sem is held for the duration of the access.
> 
> So is heapprofd a developer-only thing?  Is heapprofd included in
> end-user android loads?  If not then, again, wouldn't it be better to
> make the feature Kconfigurable so that Android developers can enable it
> during development then disable it for production kernels?

Almost all of this code is already configurable with
CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
disabled.

Or are you referring to something else that needs to be made configurable?

thanks,

 - Joel

