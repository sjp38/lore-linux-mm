Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 708A9C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:56:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F38642085A
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="NQ/9B5p6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F38642085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A5956B0003; Mon, 12 Aug 2019 10:56:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52F126B0005; Mon, 12 Aug 2019 10:56:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CF996B0006; Mon, 12 Aug 2019 10:56:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 13FB46B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 10:56:30 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A9E81180AD7C3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:56:29 +0000 (UTC)
X-FDA: 75814076898.08.mint42_72d36f83da159
X-HE-Tag: mint42_72d36f83da159
X-Filterd-Recvd-Size: 7366
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:56:28 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id r26so13665025pgl.10
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:56:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3NQFlI4lPYDkvZgs+SnZFXq303TlZRy3bgOdazYblNc=;
        b=NQ/9B5p6EJnc/jGagbLM/8utrsVRGSqpApLAwGccX5pyS3J/WcnaL76DY5ZPmNj/me
         +sOQkXutAriyMqi+oLObLZvGQLAia8jcHXEZ76S2/2iX/m6q9ZxUBAuq6hc8fExbhUE5
         WykTmRJksJRkfuwSeyqAdKimKYBeiv/vOihXA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=3NQFlI4lPYDkvZgs+SnZFXq303TlZRy3bgOdazYblNc=;
        b=j+iEvJtvWoRQ9ITuTfMgrRmsR76McvRgqYqsbCSusXFmjAbj43PMRHnS5mVwPnHlS9
         45Qu+4e/SvZzf41N9K6gp6tN23EjCKsmgAFdXRwnswi6oC55NCIz2l/0Zx9I3zGA9JM4
         2LnbvMplTrTWZRmVdhtquQJG8RA/ov86DdXYTXuFhOiLwp/0EeWCH//1aR7JHTBjWRYJ
         il4mIMQLkedvq84okuxkq/pUBfAkyyLjPJ3YDEOTqlaV1kVEHLMffiDgkMOj2VoS82ME
         CVLyJezFmXE/ZSiY8fCDSqgbc2noqZKR/M1th79QHWKVoDSBS3RhPKwKRRXgRZkq7IeD
         Ls3A==
X-Gm-Message-State: APjAAAWZFkbv/WcLoLyGQaB/o2ipQAxr0sp1QoofJ4IL7hfK8LnEjRxP
	Nwuy9+E8/AgQJ9grxK7nLyJuKg==
X-Google-Smtp-Source: APXvYqwENYmtyILjOnl4HilVvOmaVrKuBkJ28bAMVAwHSpsNFJRH+v3wmBUJf3pYNep/OXJa+KX7pQ==
X-Received: by 2002:a65:4786:: with SMTP id e6mr29905703pgs.448.1565621782717;
        Mon, 12 Aug 2019 07:56:22 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id y23sm5052754pfr.86.2019.08.12.07.56.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 07:56:21 -0700 (PDT)
Date: Mon, 12 Aug 2019 10:56:20 -0400
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
Message-ID: <20190812145620.GB224541@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
 <20190807204530.GB90900@google.com>
 <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
 <20190807213105.GA14622@google.com>
 <20190808080044.GA18351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808080044.GA18351@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:00:44AM +0200, Michal Hocko wrote:
> On Wed 07-08-19 17:31:05, Joel Fernandes wrote:
> > On Wed, Aug 07, 2019 at 01:58:40PM -0700, Andrew Morton wrote:
> > > On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> > > 
> > > > On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > > > > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > > > > 
> > > > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > > > profiles and pin points code paths which allocates and leaves memory
> > > > > > idle for long periods of time. This method solves the security issue
> > > > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > > > better results than the pagemap lookup, the theory being that the window
> > > > > > where the address space can change is reduced by eliminating the
> > > > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > > > process's mmap_sem is held for the duration of the access.
> > > > > 
> > > > > So is heapprofd a developer-only thing?  Is heapprofd included in
> > > > > end-user android loads?  If not then, again, wouldn't it be better to
> > > > > make the feature Kconfigurable so that Android developers can enable it
> > > > > during development then disable it for production kernels?
> > > > 
> > > > Almost all of this code is already configurable with
> > > > CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> > > > disabled.
> > > > 
> > > > Or are you referring to something else that needs to be made configurable?
> > > 
> > > Yes - the 300+ lines of code which this patchset adds!
> > > 
> > > The impacted people will be those who use the existing
> > > idle-page-tracking feature but who will not use the new feature.  I
> > > guess we can assume this set is small...
> > 
> > Yes, I think this set should be small. The code size increase of page_idle.o
> > is from ~1KB to ~2KB. Most of the extra space is consumed by
> > page_idle_proc_generic() function which this patch adds. I don't think adding
> > another CONFIG option to disable this while keeping existing
> > CONFIG_IDLE_PAGE_TRACKING enabled, is worthwhile but I am open to the
> > addition of such an option if anyone feels strongly about it. I believe that
> > once this patch is merged, most like this new interface being added is what
> > will be used more than the old interface (for some of the usecases) so it
> > makes sense to keep it alive with CONFIG_IDLE_PAGE_TRACKING.
> 
> I would tend to agree with Joel here. The functionality falls into an
> existing IDLE_PAGE_TRACKING config option quite nicely. If there really
> are users who want to save some space and this is standing in the way
> then they can easily add a new config option with some justification so
> the savings are clear. Without that an additional config simply adds to
> the already existing configurability complexity and balkanization.

Michal, Andrew, Minchan,

Would you have any other review comments on the v5 series? This is just a new
interface that does not disrupt existing users of the older page-idle
tracking, so as such it is a safe change (as in, doesn't change existing
functionality except for the draining bug fix).

thanks,

 - Joel


