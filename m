Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46A84C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:51:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0920E20679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:51:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="f7nrvRhT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0920E20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 965C56B0003; Tue, 13 Aug 2019 09:51:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 915FD6B0006; Tue, 13 Aug 2019 09:51:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 804396B0007; Tue, 13 Aug 2019 09:51:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9126B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:51:57 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 19EC33A92
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:51:57 +0000 (UTC)
X-FDA: 75817543074.06.cat95_2e06b966f7c27
X-HE-Tag: cat95_2e06b966f7c27
X-Filterd-Recvd-Size: 8842
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:51:56 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id e11so735528pga.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:51:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=62sEQ9UsiJhcclRMyKqZ3t5XOCcMxxKpyjm1UZtT1rQ=;
        b=f7nrvRhTXp9uue1H7nAtD3gUt/kdApcgjPByYIMpfshqNDLzNDwXkVEB23h3SYYqpd
         +Vr2PqxXbv0BcOZA2KGmmEYjCJdKHLO/HZ9759zTlvN9d2EqjoE4HHnVKZAqABbEZnJ9
         i9HxXjx4604T18/h2vPltIiw4UHhVioMF2Apw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=62sEQ9UsiJhcclRMyKqZ3t5XOCcMxxKpyjm1UZtT1rQ=;
        b=lcFuZMVnS5uNl7OXrlpOgrL5UGK7DPOY1FHWIHw1V9/sD0UHXto+q/Z7Y0trhqjpZT
         LFIZRRfx1gGQ2O1XbPZg8Ie9ZJLuD8IN8MkXvxXR7lQU1GwluYfOkOoFV0OfeSCXMuIO
         KFgwyh5bE7UCVSd4O3XGbgLDhAStiHlqqnj66QrYkFIMN+AbcjvzhOYb9cD9uhA65g35
         H4QFgGXVV0/z2TPMzCDwxHVBWF26UWFrWXbAlBFaVVQrHn689ZKqCm+BSudoXc7PHnQJ
         4JOs3/fKoL0sAfYmGzyiu0GSN3mCEJQR/9OC4NM6kHTA2JJ4o7x0tXnN/C3xo9h6Dmxl
         7y4A==
X-Gm-Message-State: APjAAAULIoFTfehzKaU2ee1zBIyV59dZ/y2yulI0Sz7jo56/tqVt9HDm
	MjQ7Y6G7Lbrlem7sBrk+69gi0Q==
X-Google-Smtp-Source: APXvYqxhO7tKD2Ct4ACAinWPlcqbL6OvBvPKuXBpuAsbrD4FXwQ3R7h+s+KsjdFosYM2UXvMiv5U1g==
X-Received: by 2002:a65:6093:: with SMTP id t19mr3676061pgu.79.1565704314954;
        Tue, 13 Aug 2019 06:51:54 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id m13sm50097285pgn.57.2019.08.13.06.51.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 13 Aug 2019 06:51:54 -0700 (PDT)
Date: Tue, 13 Aug 2019 09:51:52 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190813135152.GC258732@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
 <20190807204530.GB90900@google.com>
 <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
 <20190807213105.GA14622@google.com>
 <20190808080044.GA18351@dhcp22.suse.cz>
 <20190812145620.GB224541@google.com>
 <20190813091430.GE17933@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813091430.GE17933@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 11:14:30AM +0200, Michal Hocko wrote:
> On Mon 12-08-19 10:56:20, Joel Fernandes wrote:
> > On Thu, Aug 08, 2019 at 10:00:44AM +0200, Michal Hocko wrote:
> > > On Wed 07-08-19 17:31:05, Joel Fernandes wrote:
> > > > On Wed, Aug 07, 2019 at 01:58:40PM -0700, Andrew Morton wrote:
> > > > > On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > 
> > > > > > On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > > > > > > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > > > > > > 
> > > > > > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > > > > > profiles and pin points code paths which allocates and leaves memory
> > > > > > > > idle for long periods of time. This method solves the security issue
> > > > > > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > > > > > better results than the pagemap lookup, the theory being that the window
> > > > > > > > where the address space can change is reduced by eliminating the
> > > > > > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > > > > > process's mmap_sem is held for the duration of the access.
> > > > > > > 
> > > > > > > So is heapprofd a developer-only thing?  Is heapprofd included in
> > > > > > > end-user android loads?  If not then, again, wouldn't it be better to
> > > > > > > make the feature Kconfigurable so that Android developers can enable it
> > > > > > > during development then disable it for production kernels?
> > > > > > 
> > > > > > Almost all of this code is already configurable with
> > > > > > CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> > > > > > disabled.
> > > > > > 
> > > > > > Or are you referring to something else that needs to be made configurable?
> > > > > 
> > > > > Yes - the 300+ lines of code which this patchset adds!
> > > > > 
> > > > > The impacted people will be those who use the existing
> > > > > idle-page-tracking feature but who will not use the new feature.  I
> > > > > guess we can assume this set is small...
> > > > 
> > > > Yes, I think this set should be small. The code size increase of page_idle.o
> > > > is from ~1KB to ~2KB. Most of the extra space is consumed by
> > > > page_idle_proc_generic() function which this patch adds. I don't think adding
> > > > another CONFIG option to disable this while keeping existing
> > > > CONFIG_IDLE_PAGE_TRACKING enabled, is worthwhile but I am open to the
> > > > addition of such an option if anyone feels strongly about it. I believe that
> > > > once this patch is merged, most like this new interface being added is what
> > > > will be used more than the old interface (for some of the usecases) so it
> > > > makes sense to keep it alive with CONFIG_IDLE_PAGE_TRACKING.
> > > 
> > > I would tend to agree with Joel here. The functionality falls into an
> > > existing IDLE_PAGE_TRACKING config option quite nicely. If there really
> > > are users who want to save some space and this is standing in the way
> > > then they can easily add a new config option with some justification so
> > > the savings are clear. Without that an additional config simply adds to
> > > the already existing configurability complexity and balkanization.
> > 
> > Michal, Andrew, Minchan,
> > 
> > Would you have any other review comments on the v5 series? This is just a new
> > interface that does not disrupt existing users of the older page-idle
> > tracking, so as such it is a safe change (as in, doesn't change existing
> > functionality except for the draining bug fix).
> 
> I hope to find some more time to finish the review but let me point out
> that "it's new it is regression safe" is not really a great argument for
> a new user visible API.

Actually, I think you misunderstood me and took it out of context. I never
intended to say "it is regression safe". I meant to say it is "low risk", as
in that in all likelihood should not be hurting *existing users* of the *old
interface*. Also as you know, it has been tested.

> If the API is flawed then this is likely going
> to kick us later and will be hard to fix. I am still not convinced about
> the swap part of the thing TBH.

Ok, then let us discuss it. As I mentioned before, without this we lose the
access information due to MADVISE or swapping. Minchan and Konstantin both
suggested it that's why I also added it (other than me also realizing that it
is neeed). For x86, it uses existing bits in pte so it is not adding any more
bits. For arm64, it uses unused bits that the hardware cannot use. So I
don't see why this is an issue to you.

thanks,

 - Joel


