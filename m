Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A9A5C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F58620844
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="C6Wd4yxw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F58620844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0CCE6B0006; Tue, 13 Aug 2019 10:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBBF56B0007; Tue, 13 Aug 2019 10:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AABA46B0008; Tue, 13 Aug 2019 10:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0151.hostedemail.com [216.40.44.151])
	by kanga.kvack.org (Postfix) with ESMTP id 885136B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:25:31 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 39C388248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:25:31 +0000 (UTC)
X-FDA: 75817627662.06.tail00_301f050d3c13a
X-HE-Tag: tail00_301f050d3c13a
X-Filterd-Recvd-Size: 7446
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:25:30 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id g4so2873833plo.3
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:25:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cgcBlbXGFsc/om+/smWu+Pn0e+PGsj2TzOvbc6+E86U=;
        b=C6Wd4yxwaQCT0SiFrDTxUSIkFQODTgQV7PQEXI9kmvPnDsR4HFuL/kHGspte6crI3X
         niIRYHkysNGFVRaeTjgdQiq57VbO4gQEWfnYaaLSFYY8xqxSoVaRN0B+Y/u0fOLI71aG
         /pLkgNgZK3s+44ARW92U42yPDfe33KSorJnyE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=cgcBlbXGFsc/om+/smWu+Pn0e+PGsj2TzOvbc6+E86U=;
        b=MLZgLJuoTIwkTVVCF7xNy2c4WM2fULzi0mXTdMqhX0ICoT51vS9WVM6AP7U6RHHtEQ
         zHm6k2t+JUrBgw+Cro0bDCHrMmiqSmcLx1cIQVAowNAgiHjy6aSkezX75CDphuv8aCI0
         6WnK1StxmzKMVfPLXTVUPiKc0tXLD5eStSau2MPLcICKdEcU0FMDG5NvA8PtuQdZD001
         iDZ4qw0+6+vriFq54+t6ucuwk5EWdxY71uH+lRbxkoyfVCxvy3IcJvsJU1aCJryCv6/t
         VXNNvmdWtxwgV9zIHVrSeb5fcbA3Qqo4QnasQEQBdpt7ZiU9O6GAwYlFnpf/Ja5XySMM
         871g==
X-Gm-Message-State: APjAAAXv+8Q4AJG6f3jcZ1ENKrtz2xrX8qKaagvefs596NsXdK0l5ORD
	xWVaxWZnrx6NIRItncVhITUS1g==
X-Google-Smtp-Source: APXvYqwTcTitvpJ7cl19fmHfaEht6G7+vMW1EpqZcjp3DkM9u+O42KKZEWe7yKNHPpAxz/5bAy17gQ==
X-Received: by 2002:a17:902:a508:: with SMTP id s8mr14691501plq.280.1565706329107;
        Tue, 13 Aug 2019 07:25:29 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id r137sm24048741pfc.145.2019.08.13.07.25.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 13 Aug 2019 07:25:28 -0700 (PDT)
Date: Tue, 13 Aug 2019 10:25:27 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jann Horn <jannh@google.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	Daniel Colascione <dancol@google.com>, fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team <kernel-team@android.com>,
	Linux API <linux-api@vger.kernel.org>, linux-doc@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.ibm.com>,
	Minchan Kim <minchan@kernel.org>, namhyung@google.com,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Suren Baghdasaryan <surenb@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Todd Kjos <tkjos@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190813142527.GD258732@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <CAG48ez0ysprvRiENhBkLeV9YPTN_MB18rbu2HDa2jsWo5FYR8g@mail.gmail.com>
 <20190813100856.GF17933@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813100856.GF17933@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 12:08:56PM +0200, Michal Hocko wrote:
> On Mon 12-08-19 20:14:38, Jann Horn wrote:
> > On Wed, Aug 7, 2019 at 7:16 PM Joel Fernandes (Google)
> > <joel@joelfernandes.org> wrote:
> > > The page_idle tracking feature currently requires looking up the pagemap
> > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > Looking up PFN from pagemap in Android devices is not supported by
> > > unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> > >
> > > This patch adds support to directly interact with page_idle tracking at
> > > the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> > > the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> > > looking up PFN through pagemap is not needed since the interface uses
> > > virtual frame numbers, and at the same time also does not require
> > > SYS_ADMIN.
> > >
> > > In Android, we are using this for the heap profiler (heapprofd) which
> > > profiles and pin points code paths which allocates and leaves memory
> > > idle for long periods of time. This method solves the security issue
> > > with userspace learning the PFN, and while at it is also shown to yield
> > > better results than the pagemap lookup, the theory being that the window
> > > where the address space can change is reduced by eliminating the
> > > intermediate pagemap look up stage. In virtual address indexing, the
> > > process's mmap_sem is held for the duration of the access.
> > 
> > What happens when you use this interface on shared pages, like memory
> > inherited from the zygote, library file mappings and so on? If two
> > profilers ran concurrently for two different processes that both map
> > the same libraries, would they end up messing up each other's data?
> 
> Yup PageIdle state is shared. That is the page_idle semantic even now
> IIRC.

Yes, that's right. This patch doesn't change that semantic. Idle page
tracking at the core is a global procedure which is based on pages that can
be shared.

One of the usecases of the heap profiler is to enable profiling of pages that
are shared between zygote and any processes that are forked. In this case,
I am told by our team working on the heap profiler, that the monitoring of
shared pages will help.

> > Can this be used to observe which library pages other processes are
> > accessing, even if you don't have access to those processes, as long
> > as you can map the same libraries? I realize that there are already a
> > bunch of ways to do that with side channels and such; but if you're
> > adding an interface that allows this by design, it seems to me like
> > something that should be gated behind some sort of privilege check.
> 
> Hmm, you need to be priviledged to get the pfn now and without that you
> cannot get to any page so the new interface is weakening the rules.
> Maybe we should limit setting the idle state to processes with the write
> status. Or do you think that even observing idle status is useful for
> practical side channel attacks? If yes, is that a problem of the
> profiler which does potentially dangerous things?

The heap profiler is currently unprivileged. Would it help the concern Jann
raised, if the new interface was limited to only anonymous private/shared
pages and not to file pages? Or, is this even a real concern?

thanks,

 - Joel


