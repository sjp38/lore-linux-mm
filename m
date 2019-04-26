Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37E36C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:00:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05E33206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:00:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05E33206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6656B0290; Fri, 26 Apr 2019 04:00:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83CDD6B0292; Fri, 26 Apr 2019 04:00:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705136B0293; Fri, 26 Apr 2019 04:00:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9036B0290
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 04:00:58 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id z128so466313wmb.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:00:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eKQdDnzy8s3CfI9TPC7yczN/fZ/VaNERNg/U8SFMREo=;
        b=QR0w1jazWENlUtgb6+mtnQwpUlKQzM8S6SSFhBYNcrigWFJN6NqQIWdqYRWa6prblm
         CFp0o1UoHs9DZyXURyugS7lxx7lSoAkTPtpa6E1BjNn9A8XtZBTnKKxGFnaMeU9qtGSw
         Rk0+noThoUMaqtc7pT/6YnRyWXhgf4ei3lbi0SvXzBeSMFAJX6GRuw0FgWsKtBTEUdy8
         3gBhCvCcAIpYXFEM3qeWneCfmt6LZHiamBxgn6t1vaZt+GNwEDdNAZadJyswgowfITAP
         QZSsFmU4SO1K7NNpsQGdwFUwkd2MF2uxbCGbDppqpUpTqRa6ALr21TdCogr7dndvivAH
         peLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAVDvTUx9ewtxn99zF2tXNQl6zOgDjBycKjRDOJk46y1J62b0M5j
	7wZn7/tz7nzpJnx0PkAzbpjwLNNTw8pdVsSMVo3wguNkd/Pmqc2VUZItalXNWUz4kD1df8P4msa
	35faFjMMvja0h5c3mQ7gDBIFq3wEZEilmeJcN2CSDpITObAJOac/W36SVcZZuJYIh5g==
X-Received: by 2002:a7b:c111:: with SMTP id w17mr6960149wmi.6.1556265657663;
        Fri, 26 Apr 2019 01:00:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEJQVtntyh/+CEXYKf+Innz66tZ/aX/mOyBUY+uLN2aNqGEPcLhsV2THLXJKpHmWeuTuDY
X-Received: by 2002:a7b:c111:: with SMTP id w17mr6960084wmi.6.1556265656729;
        Fri, 26 Apr 2019 01:00:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556265656; cv=none;
        d=google.com; s=arc-20160816;
        b=lagDoUPYxL9stxvv6RLECPDTPHo6D0BnPYCR6phE+HCNu3uRGUod3YLZmjbyOpv+3m
         7j6BM84MSqSx2dVTgxwDYf3G/WsuJh0pGyH8dur2JSVVwmKmIOY0xhLIEAH9Dh/V//lq
         kQNWIiNpOb7zkWYjv7hczLgNF6ozK6oS9JC3Jc6KBhWFgB5sz/gUMpXV2SAZ4Qn7M78L
         QBwc7cTf9Z5eoIL/KitV94f99/8fnJh0qnUQbQ/BEpPnoe+8DqC3kHw6ccNASjm9Xu+L
         BKfNKYleAzkusIpoqfDIZXXrlqUKOIin4QqFDYqClg6UykJUDNcb95SPk9ZxVrc5Zom3
         Vweg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eKQdDnzy8s3CfI9TPC7yczN/fZ/VaNERNg/U8SFMREo=;
        b=O2BubvlBeIeBBWQpYlowVo4OZML8xWhaMc/sU6hIoAWaCGmNjWOz5Q97t151OT5sup
         PXhMUgNTjoSVUUsuQW9dwweBU8QNi3vdmEbtnlqDidiScreL7T8H9WF1Qo3JYKxkmN4L
         Ze4YOXC0ehETUvrvSUov75S7qh2IUYeDveHOvzzHxwBI51WHxL4FMTUGV9Z/XDaYxmOK
         0paoCpgXtBE94bVoxuTyUX6n8vPO9UC3l9pWXO+5O0dju5TsMawznvwGUFv2GZfy62Bx
         x9OdSGPqoXeYrid58oDCS5yO7Ig6lHahcI9p4mWi74Z4eq2bDB5nBlRbg6rxRYRGwdOz
         39rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y4si16752224wmj.189.2019.04.26.01.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 01:00:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJvmw-0004S4-Ru; Fri, 26 Apr 2019 10:00:55 +0200
Date: Fri, 26 Apr 2019 10:00:54 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, tglx@linutronix.de, frederic@kernel.org,
	Christoph Lameter <cl@linux.com>, anna-maria@linutronix.de
Subject: Re: [PATCH 0/4 v2] mm/swap: Add locking for pagevec
Message-ID: <20190426080054.6ngpnz2plqr4mwt2@linutronix.de>
References: <20190424111208.24459-1-bigeasy@linutronix.de>
 <20190424121552.GD19031@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190424121552.GD19031@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-04-24 05:15:52 [-0700], Matthew Wilcox wrote:
> On Wed, Apr 24, 2019 at 01:12:04PM +0200, Sebastian Andrzej Siewior wrote:
> > The swap code synchronizes its access to the (four) pagevec struct
> > (which is allocated per-CPU) by disabling preemption. This works and the
> > one struct needs to be accessed from interrupt context is protected by
> > disabling interrupts. This was manually audited and there is no lockdep
> > coverage for this.
> > There is one case where the per-CPU of a remote CPU needs to be accessed
> > and this is solved by started a worker on the remote CPU and waiting for
> > it to finish.
> > 
> > In v1 [0] it was attempted to add per-CPU spinlocks for the access to
> > struct. This would add lockdep coverage and access from a remote CPU so
> > the worker wouldn't be required.
> 
> >From my point of view, what is missing from this description is why we
> want to be able to access these structs from a remote CPU.  It's explained
> a little better in the 4/4 changelog, but I don't see any numbers that
> suggest what kinds of gains we might see (eg "reduces power consumption
> by x% on a particular setup", or even "average length of time in idle
> extended from x ms to y ms").

Pulling out a CPU from idle or userland computation looks bad. In the
first series I had numbers how long it takes to compute the loop for all
per-CPU data from one CPU vs the workqueue. Somehow the uncontended lock
was bad as per krobot report while I never got stable numbers from that
test.
The other motivation is RT where we need proper locking and can't use
that preempt-disable based locking.

Sebastian

