Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CFF0C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D71C02187F
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:55:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="iLFial3W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D71C02187F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75A9F6B0003; Wed,  7 Aug 2019 17:55:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E46F6B0006; Wed,  7 Aug 2019 17:55:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586246B0007; Wed,  7 Aug 2019 17:55:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 206306B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:55:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h27so57558856pfq.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:55:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fPDNifyL3Y36NBVemhHSXF79qGomK0S4tenrlniMG8c=;
        b=Fbost1nlOYCemWPISqFm/8PibMjxRKUUeE/V3QW3UtDoPjaut0spdphG+Su89qdNlA
         4vjh3FhO3I732HPfBpYNCRD8rgzFQ+um7Jz+Hgdm8wE8e79naVzMogFh0jRIq89uaJi6
         +dN4+jjhsOBe6S6ieEFtcKa0kzy79ldkGQgzFL7RflvFiRfbmK22B7Mn2zZmz+482dfB
         87P4KJ8wlV8wN6IrAYwow7aUAJfWnF+Q1JXQvBtG/Vd1KhKdxQUxtnuhK8EiFnG3Mbnk
         J3fGTA/zXhzNnUOozNjiiMdpg9X8790Mdm5qiTTjon6MtavTcx08kbiBlX2XrOriKTEB
         P9nQ==
X-Gm-Message-State: APjAAAU58L0BdrWcDxSD7eGyvpGtcoaNu8aC8DkUA33RItJUG5Q12HY2
	d2Bv2mlc9nrGn43Rkjk9nzog3zSUMQAsDAWn4k4i2lhiBfi0CySfVrfvAs0vu4KkNdqg8XrWNMz
	Y6YbNU4DYLWZmU6wZRA19z4+vo5BHbuownnfvl2UEqlw0jLQy7sYXV9zA5R6RRohjKg==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr10162514plb.81.1565214952760;
        Wed, 07 Aug 2019 14:55:52 -0700 (PDT)
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr10162480plb.81.1565214951954;
        Wed, 07 Aug 2019 14:55:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565214951; cv=none;
        d=google.com; s=arc-20160816;
        b=mDqwF9z8B4AqRDqcRkGAR1548LZKg4ab6XWxkQrt/U6MrTf6Bd7mjCg27FSpUdgNM1
         ialXUhXm7qIAkrlFvQZ7RiEKDjzb3wJlj1P4xkuVZx51Ujnj72NPVbhXc/66VMkoRCa9
         KDnJLSfANrDuIjZ+ko/JeX+TY7cCbVkZTxGRi2Te3zTUZZ6HHnqdlGhK/9gJeVbGY/b+
         lLzY2HnMMFkoNRGuaP9xRl6tzwNk9dnguq+rhDXwj/P/z283662IOfx1CdmMJCn2GoNU
         6H2DKW+sNqD1ti+oKVSkBO74lkM5ybptu+5zTYta3v06buLyWjW3OqFq9MKOrojtOL84
         0lGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fPDNifyL3Y36NBVemhHSXF79qGomK0S4tenrlniMG8c=;
        b=GVf8YinoXnhWq+1TlzJ8m4RBpn5QtdnGBMxdkKs2NQNcPHlZwepRPR21rM2HIb52EW
         Kom9Rhirky4f3qoDaoveiKGu0WcumgORHq4WCf0c/Tf8eOH8qGrohExWAlHJ8VrjWAm9
         8gSTn+/JRROI/YCiGSGAvvxem2MXMPsf6virP1+qc8NTO87ia3NNKj0EKiA8q6f48T9q
         SZeBUkW0/hLB/WS0Vo9HZBUwTxCtl6QGiKyJXGDTtR5O/P4DLzlO2ZD4/qct9Gbz1WEm
         uqKz/gf/8EOX5dZVUGvBd+dk5JoRl/UxfAib59yKHm6GNrT8EJms/jRwggHWU6XZj5qI
         Sh3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=iLFial3W;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor72286524pfd.59.2019.08.07.14.55.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 14:55:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=iLFial3W;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fPDNifyL3Y36NBVemhHSXF79qGomK0S4tenrlniMG8c=;
        b=iLFial3WG2Y7hC5RmH/BPZMbk7K/mSRsub86lIBJhU4yCFb7muLzqQlM2Rw/ElKGgC
         SFjKYwdRoliyNAlbyClW8nV7pvHzWz0n8BGIO7Li2Qvwc3w0FvMgmdrCGjAVrSK9JbBy
         BL0fPr4WaEXa+YoPzJ+O512HUakd8rmUXyXUM=
X-Google-Smtp-Source: APXvYqxtYbX1J2T4gE/+OoiVyWtnb2A4+C1faUKsGzqUpJz/BeHl7Ul7v7RUi0zJvoSnKkCTeSkNNg==
X-Received: by 2002:aa7:9afc:: with SMTP id y28mr11421501pfp.252.1565214951446;
        Wed, 07 Aug 2019 14:55:51 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id z4sm79672843pgp.80.2019.08.07.14.55.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 14:55:50 -0700 (PDT)
Date: Wed, 7 Aug 2019 17:55:49 -0400
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
Message-ID: <20190807215549.GB14622@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
 <20190807204530.GB90900@google.com>
 <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
 <20190807213105.GA14622@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807213105.GA14622@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 05:31:05PM -0400, Joel Fernandes wrote:
> On Wed, Aug 07, 2019 at 01:58:40PM -0700, Andrew Morton wrote:
> > On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> > 
> > > On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > > > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > > > 
> > > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > > profiles and pin points code paths which allocates and leaves memory
> > > > > idle for long periods of time. This method solves the security issue
> > > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > > better results than the pagemap lookup, the theory being that the window
> > > > > where the address space can change is reduced by eliminating the
> > > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > > process's mmap_sem is held for the duration of the access.
> > > > 
> > > > So is heapprofd a developer-only thing?  Is heapprofd included in
> > > > end-user android loads?  If not then, again, wouldn't it be better to
> > > > make the feature Kconfigurable so that Android developers can enable it
> > > > during development then disable it for production kernels?
> > > 
> > > Almost all of this code is already configurable with
> > > CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> > > disabled.
> > > 
> > > Or are you referring to something else that needs to be made configurable?
> > 
> > Yes - the 300+ lines of code which this patchset adds!
> > 
> > The impacted people will be those who use the existing
> > idle-page-tracking feature but who will not use the new feature.  I
> > guess we can assume this set is small...
> 
> Yes, I think this set should be small. The code size increase of page_idle.o
> is from ~1KB to ~2KB. Most of the extra space is consumed by
> page_idle_proc_generic() function which this patch adds. I don't think adding
> another CONFIG option to disable this while keeping existing
> CONFIG_IDLE_PAGE_TRACKING enabled, is worthwhile but I am open to the
> addition of such an option if anyone feels strongly about it. I believe that
> once this patch is merged, most like this new interface being added is what

s/most like/most likely/

> will be used more than the old interface (for some of the usecases) so it
> makes sense to keep it alive with CONFIG_IDLE_PAGE_TRACKING.
> 
> thanks,
> 
>  - Joel
> 

