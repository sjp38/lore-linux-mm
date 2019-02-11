Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9C8AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:13:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B0DC2229E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:13:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B0DC2229E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F23FE8E013F; Mon, 11 Feb 2019 14:13:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED3C38E0134; Mon, 11 Feb 2019 14:13:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC21F8E013F; Mon, 11 Feb 2019 14:13:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81E868E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:13:53 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v16so4287wru.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:13:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=96XIetx0F5vMgZs7wBvKOsKugT1aCyIl2LVjAYXWnq0=;
        b=U2RNwAVVF402ddgBF3ps3sCowgL60RFzF80R2tgFqHtN2jwVch4mBADMd/YIx/0zGl
         7L5pVKLskeyqk/4SXMt6GMlHZ0NCBqM5thdswImeRdeFoysakbwt4SDU7KEUOmZcHQlg
         y+IgKRpJdGb0zk08D3U3+RObO138KIC8uA96BGQl4W3MHPGRVAHMMY12rz9NUzF5/M9m
         fzNt9bvAV2lMU8+bcnwpeLML+QwzT1S40XNOu73i0gphnK1gPcsLHTkUfxMPYRbNKBws
         kQ2yviWJ0FCREtE1Cxn/m4D3H2HS0KOYOPPWZ4e7msCx0IGkdf4Z9/9J99lCh1kOB/+q
         deLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: AHQUAuadWRFFLs74ErUZMTAQUh3RjXkEHpoIKmF2nHPYofQJrRd7kNPV
	10SBdTO8pswjhpaDV6UbVFUa/JxS5LRaNVw+VmEqQZJO9qd0zaoeyZr94i5QdOsuXbsRDEIe1hq
	3yQq9TEA5AXoiFzcIMf70LV+5QXyI88tNNI8k4B76uvrDRlQHX00hEjnJQo5+ju8smA==
X-Received: by 2002:adf:f3d0:: with SMTP id g16mr4349613wrp.29.1549912433076;
        Mon, 11 Feb 2019 11:13:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaBRcNZljqwqOXbiXvLjTFq/9I0HQQ2vrRvaIS0+2+QRlrY2oxHQH5ShdODvW71lebEFuj/
X-Received: by 2002:adf:f3d0:: with SMTP id g16mr4349580wrp.29.1549912432277;
        Mon, 11 Feb 2019 11:13:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912432; cv=none;
        d=google.com; s=arc-20160816;
        b=JxjgOLjclcjeEZ0Qtd5LuODvVwW/N0prOHpj6bnRP5GFbvghewH+UrHPaMgh4Q4sym
         eL7KPzyu6ESVa+GmR2gVADmS+r9cEnGNeG1lzOwmEixIaWAmviASSXWE5+c06vxVzzsA
         /0MDY4KSLDS3zWy4JkQIb6P5PC3yjdqP+/Kez2EKU0F2UR6HIJSG8EEtAWkprIpJaCEk
         8qEfeLr6uMJU4VKOKuLK+A1+dnsT9WEavJD5S7opDnZKSUlt6gp+9zdODwDjvz9WnHrt
         qSZufAW1tfMU72MhpK9s6R92it4C23NsB2hZSseWLN0p00dovVlAXLo493GmWoPfIiU3
         AsyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=96XIetx0F5vMgZs7wBvKOsKugT1aCyIl2LVjAYXWnq0=;
        b=ltSELVBXArrd2mawCrNqHHkVZqMDQ3Vbv3SOr0n+X+irN3C4qnrJxfG2LSPUY5BetX
         E6o1QTSapoHEoX1JqCToEPow2sgmahkcCQunSBGrk2rzMFMkBsUBiaftZS89jeOnejny
         APrQ5IhOCSwmnsaHJNNlaFtMOOerxoC0pdQi0Rx/zuGhPWVtTntPgwDYqNyzJeooDWsN
         rZEQtVb06koHIrhAuIg4/5h8JvgNMzdOqiRZhpJrmEAIxYwZzeuSyC4zqcQuMe1Kudll
         q+/zVU3a8yJp6Uuc6pOIKhxN03zC+P5Sd6QowMx+cVJBrzDqFCrT1VMF+o9aP15QY4EU
         aolw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o15si7885816wru.227.2019.02.11.11.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 11:13:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1gtH1V-0001A2-Hh; Mon, 11 Feb 2019 20:13:45 +0100
Date: Mon, 11 Feb 2019 20:13:45 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211191345.lmh4kupxyta5fpja@linutronix.de>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190211185318.GA13953@cmpxchg.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-02-11 13:53:18 [-0500], Johannes Weiner wrote:
> On Mon, Feb 11, 2019 at 12:38:29PM +0100, Sebastian Andrzej Siewior wrote:
> > Commit
> > 
> >   68d48e6a2df57 ("mm: workingset: add vmstat counter for shadow nodes")
> > 
> > introduced an IRQ-off check to ensure that a lock is held which also
> > disabled interrupts. This does not work the same way on -RT because none
> > of the locks, that are held, disable interrupts.
> > Replace this check with a lockdep assert which ensures that the lock is
> > held.
> > 
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> I'm not against checking for the lock, but if IRQs aren't disabled,
> what ensures __mod_lruvec_state() is safe?

how do you define safe? I've been looking for dependencies of
__mod_lruvec_state() but found only that the lock is held during the RMW
operation with WORKINGSET_NODES idx.

>                                            I'm guessing it's because
> preemption is disabled and irq handlers are punted to process context.
preemption is enabled and IRQ are processed in forced-threaded mode.

> That said, it seems weird to me that
> 
> 	spin_lock_irqsave();
> 	BUG_ON(!irqs_disabled());
> 	spin_unlock_irqrestore();
> 
> would trigger. Wouldn't it make sense to have a raw_irqs_disabled() or
> something and keep the irqs_disabled() abstraction layer intact?

maybe if I know why interrupts should be disabled in the first place.
The ->i_pages lock is never acquired with disabled interrupts so it
should be safe to proceed as-is. Should there be a spot in -RT where the
lock is acquired with disabled interrupts then lockdep would scream. And
then we would have to decide to either move everything raw_ locks (and
live with the consequences) or avoid acquiring the lock with disabled
interrupts.

Sebastian

