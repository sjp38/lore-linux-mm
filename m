Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 191E8C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 17:00:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D617820880
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 17:00:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D617820880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 763866B0003; Sun, 14 Apr 2019 13:00:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 712CA6B0006; Sun, 14 Apr 2019 13:00:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 628F16B0007; Sun, 14 Apr 2019 13:00:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 159B06B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 13:00:52 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id q3so12805195wmc.0
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 10:00:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=/f43oPQ9tdnfUN30pUlmaJB8+1vU0+oCCPIn+6xYknc=;
        b=sNU4qMZNJbKqhg3fwbtnDFfA6CN9Ak/PakmIIuAwN1ohK0UT9RC9jtcH3/W5zZZ3CX
         ZAd+/6++RTK16iekjlmlM68pepU/WhPATE8Ee/FhAtALp3aSPk8s8f4IFeaV0Xheh4A8
         qSNUE1r7YfR0WhMr72w2R5UiD5GfBFbmzeUVljcVL60Dw0UrkG+p4DL+1S0toahIbWhm
         NTN9nGakQEItUM5c2rvsI5o/9AXxxMQnBXAnec+OKAUIjEoxwfoyVkJ0KdM/4eVt0OrU
         xFKMhd4b2QBQTemaCtnqQdF4NNgNmjgoa5+S6/izQk29eW4FD8brvAud1MBpXWb4kvAV
         A9ZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWZ9BbJAy2p6O+8mUwCJnPb5qTm/lukUIe3EfwS9fqTA3l+FDf4
	Tp+GwH6I3SkYpgGUJovIFVTcVKwuMhQqG9YMvjXz2GlNkarb9pJscsHZZ+2tf2pgs/mAU2MMGIO
	fkxDWa6Js28ykIOJS8bKnnR6ceOyDKahnUVa6rGUUHeiF+72nrP01LASMRrgMiVjLOw==
X-Received: by 2002:adf:f70e:: with SMTP id r14mr44078344wrp.37.1555261251635;
        Sun, 14 Apr 2019 10:00:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBMtlGmCnbsRx+Nrcg9lBkt/eHqv0Iq0Xiz2Xh+KdW0wlivqGhKqbjKxQ84z+12tR9Z8s/
X-Received: by 2002:adf:f70e:: with SMTP id r14mr44078312wrp.37.1555261250894;
        Sun, 14 Apr 2019 10:00:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555261250; cv=none;
        d=google.com; s=arc-20160816;
        b=WfBQaeGV+RWsBZLUd0ScQ0p68Q/QgwTimb6ZvHKHxHlBn8PD6r9sQEJu6Ij07JU6bY
         Vt75rSAliOpUHVMm8fNqAaPDXoxYyv26uZdSc0OYBli5BFEIHgrenrmJHrntnIS4heWJ
         pi+of87mkL5fIpwxpgs1ii70TdCfzf97xyFFlfLDQ2VtJNjEgphd8wfI8wPAgLBOSyOw
         eOZuOzKAFK52x8QziO90/T6AdZ5e/litP1Ka+EoyGt7DPbDru4Q9d+toBorQbyIKFMxP
         EfxCEhXXM435Zv4R1ihCBvy2G/s0wUodiitIYfN424VXdPqzRjr6OR6uaRd/bwQ9c/od
         VXzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=/f43oPQ9tdnfUN30pUlmaJB8+1vU0+oCCPIn+6xYknc=;
        b=HuK4olxSfITxixnQwSgiIxrwP8yT2YmYij2DnaoSgTJYbvneowV0ybbLGd4/tBXLei
         1JZz5VhbBNenyio5q5+TMjfif5IYKfRH5YssxcxqfF+FEQ+TPXa9WO2Oyr/9iY9f7hCL
         FNtDs7QmniS3U2rR3+7odmRVQmrX8GmvlMiowR9hHGu9KGy1ALFDbIBb0JvnKPGjwIK7
         pI43yOhNLQ1h1sMs0gfhQAJKHfV8fZs65DXumdajI49SjzZQaOO6oFZzLL+COnv98vMH
         nVq6Oh9eqieQin+Zp8JZ6m+SCwi4vF59HvAE2nDFK2wdJVQswzUwmVapxRErtARhhEWJ
         0aHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x6si9124725wmk.43.2019.04.14.10.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Apr 2019 10:00:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hFiUg-0004Ov-JP; Sun, 14 Apr 2019 19:00:38 +0200
Date: Sun, 14 Apr 2019 19:00:37 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, 
    Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, 
    Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, 
    linux-mm@kvack.org
Subject: Re: [RFC patch 25/41] mm/kasan: Simplify stacktrace handling
In-Reply-To: <alpine.DEB.2.21.1904141853530.4917@nanos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.21.1904141858300.4917@nanos.tec.linutronix.de>
References: <20190410102754.387743324@linutronix.de> <20190410103645.862294081@linutronix.de> <20190411025509.cslu3nq27g7ww6qu@treble> <alpine.DEB.2.21.1904141853530.4917@nanos.tec.linutronix.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Apr 2019, Thomas Gleixner wrote:
> On Wed, 10 Apr 2019, Josh Poimboeuf wrote:
> > On Wed, Apr 10, 2019 at 12:28:19PM +0200, Thomas Gleixner wrote:
> > > Replace the indirection through struct stack_trace by using the storage
> > > array based interfaces.
> > > 
> > > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > > Cc: Alexander Potapenko <glider@google.com>
> > > Cc: Dmitry Vyukov <dvyukov@google.com>
> > > Cc: kasan-dev@googlegroups.com
> > > Cc: linux-mm@kvack.org
> > > ---
> > >  mm/kasan/common.c |   30 ++++++++++++------------------
> > >  mm/kasan/report.c |    7 ++++---
> > >  2 files changed, 16 insertions(+), 21 deletions(-)
> > > 
> > > --- a/mm/kasan/common.c
> > > +++ b/mm/kasan/common.c
> > > @@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
> > >  		 ptr < (unsigned long)&__softirqentry_text_end);
> > >  }
> > >  
> > > -static inline void filter_irq_stacks(struct stack_trace *trace)
> > > +static inline unsigned int filter_irq_stacks(unsigned long *entries,
> > > +					     unsigned int nr_entries)
> > >  {
> > > -	int i;
> > > +	unsigned int i;
> > >  
> > > -	if (!trace->nr_entries)
> > > -		return;
> > > -	for (i = 0; i < trace->nr_entries; i++)
> > > -		if (in_irqentry_text(trace->entries[i])) {
> > > +	for (i = 0; i < nr_entries; i++) {
> > > +		if (in_irqentry_text(entries[i])) {
> > >  			/* Include the irqentry function into the stack. */
> > > -			trace->nr_entries = i + 1;
> > > -			break;
> > > +			return i + 1;
> > 
> > Isn't this an off-by-one error if "i" points to the last entry of the
> > array?
> 
> Yes, copied one ...

Oh, no. The point is that it returns the number of stack entries to
store. So if i == nr_entries - 1, then it returns nr_entries, i.e. all
entries are stored.

Thanks,

	tglx

