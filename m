Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B5F0C28CBF
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:26:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7EEC20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 17:26:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7EEC20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1533C6B000D; Sun, 26 May 2019 13:26:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 104026B000E; Sun, 26 May 2019 13:26:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0D826B0010; Sun, 26 May 2019 13:26:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4AAF6B000D
	for <linux-mm@kvack.org>; Sun, 26 May 2019 13:26:10 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y204so3516899wmd.7
        for <linux-mm@kvack.org>; Sun, 26 May 2019 10:26:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uBxgdWpNrCpZkjyq48bAbxY/E4kBjXC2I2OkPOfuQK0=;
        b=CgDaerzYyGxnZLGLRkqORZjTh3p+IEm8cklr6/cOKwPStLhpLaU9Flib8MjjCraQyT
         serBZDTamqgnZZo/lXf3IR1oquFm8IrCEXzCgZS854CRrS9R25E3q4I6hEiEribjSEf/
         BOvpjdUmL0NHGKeLS97JNckPP3wU1/m2LT5rc9shjQ2hiJThZr4AS+mTBEYHKcYMHWP+
         dF9DKqc2HRu2q9n1NqpIW+iEgehiY79EUITCE5OaLRtlTPLgqAe5m1gJsQs5PvGjWINx
         djcmj7OBP7aMsyGYpOcJL7fn5Hb/dWsFQiQb9AGN+0gsObgw4jcPiS4mYLWsfUADuT31
         QemQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAW2BLvyIYU/Wu1pbEga36ivvySTDj/mVhmoj9mbEVqTkFWLB/ar
	eYgXJkzM8FabQVvvGs0qqwepUVLnPCBRDhfhIpbTo0yB4FVWJxjIpLty3xzKeuhftS3PeKvaFnT
	t744ZxUaOLqgRM+Mlr0oUIc0EsGCHLZNE0ijiFQp7mQvaMRiAiepQCZh1zpWMKGQ=
X-Received: by 2002:a1c:f009:: with SMTP id a9mr22333750wmb.110.1558891570055;
        Sun, 26 May 2019 10:26:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLnt9/X6/4a4HuhoYDwChSLOcC+n1fwpZipp25oiksNa+a5visqlIrZmTJl9PBOmvbNnmN
X-Received: by 2002:a1c:f009:: with SMTP id a9mr22333702wmb.110.1558891568874;
        Sun, 26 May 2019 10:26:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558891568; cv=none;
        d=google.com; s=arc-20160816;
        b=WpylSwv3NK2Kc1i6sv7LHQQqoJt5zVdOCQe4Fc3haueiZJ2Y2a2WYpwwgRVTHtHX0k
         +apT119woQ2xDh5z690BWab6OVRf/c8/B8F+teh7TsF7ptz9HRQBZnw7UzQbTiTe7xFp
         OxnH/iTB/1wt1hCakapmXbxzGQLHqPfN7TCC5nmDw2A3NbOYv5u/uZAD/hcEOPY0Ao0f
         sdP/4CzPtW4zxTIWpwRxZfehaiFUgS0i7DIlyHG8xxYkvtaI1OgNh2wnSSUaii4AILrQ
         N8NVhvlPOSSgYwPbwW+tgjRNXu2IM5Rmy0O158Eob+eRHX39clad/yjy7b3g1P+J7AA8
         Jw7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uBxgdWpNrCpZkjyq48bAbxY/E4kBjXC2I2OkPOfuQK0=;
        b=bTGIgSXkaIEHp78X2j1ijKFCwSA7OSu92DYiStieF/g1g3zCfPcTROsqqkN5EQ/v3H
         orhqj5qryqyc+1YHZTyaKs01u+27RRSO4t56ADVpnqGWObf/6uE9xWAswQWhaa8jf7/e
         lMt6boDrQHSy93fvqgsYcG0MiCa8Q0ouzmJYzKJTRSd6Z8ZXNwKlaeSQnjx/P6GaNY2O
         9/Gk1K0zTEb1q09cNqvoHxUw5yNn92kmUwImkoF0FKT8C9BiALZ1AjCzn+siAzeifxa2
         hcVtHw1U2D9LoiK3nQKv/+GysWc/T2DIUIAqRXSOlw/6zSs8F3YWSTYOm+AWNw6qhwqq
         EetQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id r5si6482417wma.126.2019.05.26.10.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 10:26:08 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 021E4803F7; Sun, 26 May 2019 19:25:57 +0200 (CEST)
Date: Sun, 26 May 2019 19:25:09 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Hugh Dickins <hughd@google.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-ID: <20190526172509.GC1282@xo-6d-61-c0.localdomain>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
 <20190522194322.5k52docwgp5zkdcj@linutronix.de>
 <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 2019-05-24 15:22:51, Hugh Dickins wrote:
> On Wed, 22 May 2019, Sebastian Andrzej Siewior wrote:
> > On 2019-05-22 12:21:13 [-0700], Andrew Morton wrote:
> > > On Tue, 14 May 2019 17:29:55 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > 
> > > > When get_user_pages*() is called with pages = NULL, the processing of
> > > > VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> > > > the pages.
> > > > 
> > > > If the pages in the requested range belong to a VMA that has userfaultfd
> > > > registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> > > > has populated the page, but for the gup pre-fault case there's no actual
> > > > retry and the caller will get no pages although they are present.
> > > > 
> > > > This issue was uncovered when running post-copy memory restore in CRIU
> > > > after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> > > > copy_fpstate_to_sigframe() fails").
> 
> I've been getting unexplained segmentation violations, and "make" giving
> up early, when running kernel builds under swapping memory pressure: no
> CRIU involved.
> 
> Bisected last night to that same x86/fpu commit, not itself guilty, but
> suffering from the odd behavior of get_user_pages_unlocked() giving up
> too early.
> 
> (I wondered at first if copy_fpstate_to_sigframe() ought to retry if
> non-negative ret < nr_pages, but no, that would be wrong: a present page
> followed by an invalid area would repeatedly return 1 for nr_pages 2.)
> 
> Cc'ing Pavel, who's been having segfault trouble in emacs: maybe same?

The emacs segfault was always during process exit. This sounds different...

I don't see problems with make.

But its true that at least one of affected machines uses swap heavily.

Best regards,
								Pavel

