Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9990AC10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 623E42084E
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:54:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 623E42084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2FFF6B0003; Sun, 14 Apr 2019 12:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB8AB6B0006; Sun, 14 Apr 2019 12:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D83D56B0007; Sun, 14 Apr 2019 12:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8996B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 12:54:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k4so12982072wrw.11
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 09:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=83TZUgrzduZsm5cC2u3+y4yHevoFHWLwY+17Mbm6Nms=;
        b=YFR3Abwi0jBpdbygJqqay5l1mY7vuKGu5/BZ7Ap3uxBhU1tv4NOy7aXGV2Oatm22u/
         eBn0iPTgqQIWdUBso4Q7kQ7bOf6cKimTE9aEZsp5Ki7fFAyTL9XeAfALqpz7OZMDBCCX
         9gMmIHDpCU0I3nCce2U4v6Lo8aJSRbHsLIyQm/g4FQww3FVBzCDMM/5HuDORHrpHqShf
         V4TYpr3WSYdQrLvkVx/aUKZ/95hsiNv/b0x2p7/0QJY/bbXKMbDtGTUC+XUz7KajDsxr
         61h0snWjM++NZnk6xENwz5+0GDtC4xq4tBBp99I5JoPau4KE7INcUxLUUIwLUvOP84oN
         LvoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVD5FCS9j0A9cCHZpQi0OgOA9wfLLX/J5ZLhwi/uFifojV9UuKn
	cR4Iox1da81XRz+JhmqfuYczQXBlcw581tedNASoVecuuTv7wGuV1DjG6rqwHiM54gLmmJNV48g
	Z6H3zXBMRXWU9UYjmjmwiyySxm+795Xq2M+eAdAy3EfZgr/Yp/s5z8MoCmJBwRYOP6A==
X-Received: by 2002:adf:c18d:: with SMTP id x13mr38537278wre.246.1555260872170;
        Sun, 14 Apr 2019 09:54:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVVFZucoC5IIoeQrLzxEKbe7At/P4PIaaubnV964OfVRSgfMWmgSBp5x/Jh/Mu9ntUnxHo
X-Received: by 2002:adf:c18d:: with SMTP id x13mr38537246wre.246.1555260871344;
        Sun, 14 Apr 2019 09:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555260871; cv=none;
        d=google.com; s=arc-20160816;
        b=yDnDg/QcoZjLIEzwmw6SB5R4L+j+xWoG6QISEK+0TWNr5vDuhJyErhr4tD9EhLv/gN
         L6xntG0W8BZaLAQqe9qBKSqyc2w1UaaVtlReikqWNJaNZYVv0ecXuVIHBGSVeHCxnSRU
         Zta6HkIscGIxBbD5h8+L2sVfrf89rQFgnItg4Z127a/W4yjfloiilMb/newrI1Ei9WnV
         ridYuVoXZ6DLwwgeNC8/Xd41aY9UaPd+qtdmok6LtW7fM5Y+JS6GxMIcSq4i3ALXuhev
         GrrQTInNj1ipDvNz3PeduWrrqTDXPsQNbaiNWmEgobbt+WBIGzyCd9BwqnvsYSvj10Gv
         VW9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=83TZUgrzduZsm5cC2u3+y4yHevoFHWLwY+17Mbm6Nms=;
        b=IP4IajlN5htnggDhm4Ae8vqDAhHKbcApCR+NhmFb5Z1wFRNoSsu/SOyDFrYaSt1MRZ
         im+fK76jOtGx533tzzD/2pYWG5DQo4FICOKbDlBhs6rfFH19xoKoIUAhEaREaJxfhFq6
         YtgS5Y9EEn6fN34n6y0QEMZJQx2KtYFYWAjCfNok5qUtiDN12lY1jVKWw39zFzuFzm+n
         5VAwON3RC/ni/x5EQ63H3D9xvtXc0Ko4xTJIBYNENcndFRmdSxvXCIgA365ReYMbb2L8
         GMp6LZjumz6QDLQjAD6lk8oMB7kXD5J790uGns7SSdvzIWMQWRTmJ2is2FroTcpoyVwX
         wUsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g63si9343297wmg.129.2019.04.14.09.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Apr 2019 09:54:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hFiOb-0004Dz-5t; Sun, 14 Apr 2019 18:54:21 +0200
Date: Sun, 14 Apr 2019 18:54:20 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, 
    Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, 
    Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, 
    linux-mm@kvack.org
Subject: Re: [RFC patch 25/41] mm/kasan: Simplify stacktrace handling
In-Reply-To: <20190411025509.cslu3nq27g7ww6qu@treble>
Message-ID: <alpine.DEB.2.21.1904141853530.4917@nanos.tec.linutronix.de>
References: <20190410102754.387743324@linutronix.de> <20190410103645.862294081@linutronix.de> <20190411025509.cslu3nq27g7ww6qu@treble>
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

On Wed, 10 Apr 2019, Josh Poimboeuf wrote:
> On Wed, Apr 10, 2019 at 12:28:19PM +0200, Thomas Gleixner wrote:
> > Replace the indirection through struct stack_trace by using the storage
> > array based interfaces.
> > 
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > Cc: Alexander Potapenko <glider@google.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > Cc: kasan-dev@googlegroups.com
> > Cc: linux-mm@kvack.org
> > ---
> >  mm/kasan/common.c |   30 ++++++++++++------------------
> >  mm/kasan/report.c |    7 ++++---
> >  2 files changed, 16 insertions(+), 21 deletions(-)
> > 
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
> >  		 ptr < (unsigned long)&__softirqentry_text_end);
> >  }
> >  
> > -static inline void filter_irq_stacks(struct stack_trace *trace)
> > +static inline unsigned int filter_irq_stacks(unsigned long *entries,
> > +					     unsigned int nr_entries)
> >  {
> > -	int i;
> > +	unsigned int i;
> >  
> > -	if (!trace->nr_entries)
> > -		return;
> > -	for (i = 0; i < trace->nr_entries; i++)
> > -		if (in_irqentry_text(trace->entries[i])) {
> > +	for (i = 0; i < nr_entries; i++) {
> > +		if (in_irqentry_text(entries[i])) {
> >  			/* Include the irqentry function into the stack. */
> > -			trace->nr_entries = i + 1;
> > -			break;
> > +			return i + 1;
> 
> Isn't this an off-by-one error if "i" points to the last entry of the
> array?

Yes, copied one ...

