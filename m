Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA8EDC742CA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:00:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DCE021019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:00:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DCE021019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2D728E015C; Fri, 12 Jul 2019 12:00:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E03C48E00DB; Fri, 12 Jul 2019 12:00:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40348E015C; Fri, 12 Jul 2019 12:00:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 820478E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:00:55 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id h8so4490796wrb.11
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:00:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=YGyoAi4GqcaNnCz4i2Tl/uvMTRPEWr5xeeFUMv8DjT0=;
        b=IO7B53qnY5EiSkRNPYXwyJDVsopdUemofVInBS8pNmZFsA1SLKAo6WR1fs2LgY5L+Q
         drTJmJyLLAMyl8niyfpdJifQXHrtoFFlO4UdWAN+kF3BVsT6qfRekGIa0M73C+Biayqw
         ObkSDwQpE+bZzK5+b8HNQoc7V/a7N8csjxnn/ydUy3eMMp2P9X2+L4Vnf51Xe5jVi9ao
         IEac+XzjgBO6WltDPyFfjFyv+JH8sIAmAWu24fG/3hp235t1yQc0b9d1NNcRox2bnoNF
         smht4IzAs9nFqu4bwtBkqcbRWKzTMbMA2e7Jmt7Ksft+oM0hvLhrcmgopCq2EVxAMoq7
         8yVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW1oGNloxeSK6LySTwWfgZd6oHOty6WKQFEMNoSbVf7fWh4u2em
	MSC9/+XDoi6tFibVQkJpGVB/USYru4wa9VJETh1ei/gPnwn/t0xk4LRDblwVrbZtUBYE9y4L8G2
	5T8adG1+A56rvTQximbW659LA6xWfImx1JIgLI7hrvgmH8T1i2QFsylyQPVgtx/w7EA==
X-Received: by 2002:a5d:53c1:: with SMTP id a1mr12653195wrw.185.1562947254942;
        Fri, 12 Jul 2019 09:00:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2qWXd7nIcF7cjJTcocnkxALyVnh4/p5eh8nAUEpICjP6sN54sB01oNz0G9EER9HvUNq+F
X-Received: by 2002:a5d:53c1:: with SMTP id a1mr12653128wrw.185.1562947253931;
        Fri, 12 Jul 2019 09:00:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562947253; cv=none;
        d=google.com; s=arc-20160816;
        b=aCQElKLIxAwU57dFbUQIYXkdqlC3sPqeKorEJ0iXPYtlxUk32pbChxldsR6uD8wZlJ
         9InmO5KI10F+925eqz64gEXMWFRC8/hunkRBdfrZAoUUKpP42gA31gyQVS9WCGtaxkkJ
         yZVfnSIz5T3bJyFj55/NU5uNqPx5hyVa41+vZinksGwGV5JUbqqWteAgaBdW2SifFwN+
         Y0MyLmKuN+6n6YOJ0UFj75ZeQvokEmCsZBWOQ67WnEj4U4AqFLmOHRJd8b4fpx9JGTdy
         0kVWtu8NwNWuzSfltb6OPtrCkB6H5MyhPt4IW+Rc4xtN7VuDQW/2gNN1XTzj9uAI69Zh
         Z+gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=YGyoAi4GqcaNnCz4i2Tl/uvMTRPEWr5xeeFUMv8DjT0=;
        b=ArliB3iH8MuBrk9PlBJEZZLd83pl04hYdyIZYgcL+iZC+we/S0eyrco0/BhbJuhmiI
         is0gKp/16Nk81h07abtko27TiS9gm/PgupiD3RTpuIHJzfrszsWJJRILhZ6myhkaEat4
         xnkHuS5//NeM1mb0YW71K/fSB6kZNdWgrptsXvIbVM4+MpIKrtDzSB+MfE6jPu7wG7aw
         +lRxnW0OfUa+M7/Z0JJ77aYpWmFlLEkzLZL1PMy6APsAvqeYQsRL2fZvjs/dJaU9rngv
         lgK2nkf9K/Lim0vT8bRHhtCGHEmU0uzS2HKSn5Yf3gwPtG+rgXp7kaVEGSnElaP6Pz3Q
         YObQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id x8si7929517wmk.26.2019.07.12.09.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jul 2019 09:00:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlxyU-0004Ej-To; Fri, 12 Jul 2019 18:00:43 +0200
Date: Fri, 12 Jul 2019 18:00:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
cc: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com, 
    rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, 
    dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, 
    kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
Message-ID: <alpine.DEB.2.21.1907121751430.1788@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de> <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019, Alexandre Chartre wrote:
> On 7/12/19 12:44 PM, Thomas Gleixner wrote:
> > That ASI thing is just PTI on steroids.
> > 
> > So why do we need two versions of the same thing? That's absolutely bonkers
> > and will just introduce subtle bugs and conflicting decisions all over the
> > place.
> > 
> > The need for ASI is very tightly coupled to the need for PTI and there is
> > absolutely no point in keeping them separate.
> > 
> > The only difference vs. interrupts and exceptions is that the PTI logic
> > cares whether they enter from user or from kernel space while ASI only
> > cares about the kernel entry.
> 
> I think that's precisely what makes ASI and PTI different and independent.
> PTI is just about switching between userland and kernel page-tables, while
> ASI is about switching page-table inside the kernel. You can have ASI without
> having PTI. You can also use ASI for kernel threads so for code that won't
> be triggered from userland and so which won't involve PTI.

It's still the same concept. And you can argue in circles it does not
justify yet another mapping setup with is a different copy of some other
mapping setup. Whether PTI is replaced by ASI or PTI is extended to handle
ASI does not matter at all. Having two similar concepts side by side is a
guarantee for disaster.

> > So why do you want ot treat that differently? There is absolutely zero
> > reason to do so. And there is no reason to create a pointlessly different
> > version of PTI which introduces yet another variant of a restricted page
> > table instead of just reusing and extending what's there already.
> > 
> 
> As I've tried to explain, to me PTI and ASI are different and independent.
> PTI manages switching between userland and kernel page-table, and ASI manages
> switching between kernel and a reduced-kernel page-table.

Again. It's the same concept and it does not matter what form of reduced
page tables you use. You always need transition points and in order to make
the transition points work you need reliably mapped bits and pieces.

Also Paul wants to use the same concept for user space so trivial system
calls can do w/o PTI. In some other thread you said yourself that this
could be extended to cover the kvm ioctl, which is clearly a return to user
space.

Are we then going to add another set of randomly sprinkled transition
points and yet another 'state machine' to duct-tape the fallout?

Definitely not going to happen.

Thanks,

	tglx

