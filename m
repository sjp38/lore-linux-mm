Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04A3CC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E922206BA
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:23:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E922206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E70A36B0010; Thu,  4 Apr 2019 12:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E21396B0266; Thu,  4 Apr 2019 12:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D12F76B0269; Thu,  4 Apr 2019 12:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7566B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:23:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id m13so2242617wrr.17
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:23:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4d7JS+kMl8U7gzVO11CVk5n0R5nFaT+fxqoESXqkq28=;
        b=KcTQ7JDSCw4hzLdJyDwyF8Nvav5DO9+doRlO94Oja8RU/tBKVcT4PzWqtwL/MPkhqj
         PrIAvUhhYom63YDFFKZSDb7+vtNF8Y2c3w8fSyvsoI43w2h85M7YVLW4BY/yGlAXvGQO
         hprVBsLWJi2YZ+Rm9nkX6BCYqhFaTvze2gIhZo4MX/ryHtV2O0YqHlqE61Z+6ZUkXF52
         vvoY+/o2x/Z+VGToI0zsOYbWnYWiyvIQGXNPa06nu2a/H9UTeSfni3MBG2i0L1VPT/lu
         ERAnVJoMcL1BKb+gi5YE14jcDymsKOnL8icrHiNdJ9xffLtcZvnCmYEg+WP0B9l3WiNa
         MoVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAVGnavwtuFyn0B4w9JVthHSI8ELkiCYoZgPExgq8DaVelYtfrX/
	iFYm2uG8hjqE0sjK3osFlfba6eKvsQZiQ031w9LSdIrXDVlQhnTl0tbjB48Zw4s2MDIAZ0OSp+A
	Hj+zdjyf0p0/ocnb97IFqaZCLQ82Uml0oGlAVJqiEvK0kpw4WLOVu3UxLuC59HXjqDA==
X-Received: by 2002:a7b:c3c9:: with SMTP id t9mr4539078wmj.131.1554395038032;
        Thu, 04 Apr 2019 09:23:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyey7q62pMuPNOvemCRCJfzP6XQEJDHh+9CknBHyh9z4VTXQ91DWEKDejm4FNBILqyUxsHM
X-Received: by 2002:a7b:c3c9:: with SMTP id t9mr4539021wmj.131.1554395036839;
        Thu, 04 Apr 2019 09:23:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554395036; cv=none;
        d=google.com; s=arc-20160816;
        b=i9k2YuhE8IwB+uLHXWRRQHjI/WNtAEnBeOxCsJHlUaJm6O+ddrOHIdWggxnlamZlXK
         CtXaV9V8EhJ5X5H0ebXxgYYaQ+3OkksyazaIaZOq3rQmjz+1UdzYPjypWagyHzq1ON05
         GVQKpaVpVI9qFBmL4SqShOIXgkVCwAdqH2h6p45T6kTsQy3Y28686KF38CG/Ip7PcABX
         T0U0Sw8FjmAckRycXBH2osyg8evWgOv4xeHxceVF+1z/EfmBj4zsdckqCNX2bh4uWiuG
         tnr6A3IH8zkjip6gB63rszhn/G8/iRKZRoWrsHS8Ks67EgFvukrS2KOZdoAoP+JY4P9/
         iSVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4d7JS+kMl8U7gzVO11CVk5n0R5nFaT+fxqoESXqkq28=;
        b=AgsjTJ6um6phOYVlcPaJx5l8wJKA/zcY5LFePRDBEIvuhRbRQ24jPUSlTsq0Yqt6WK
         ekaTJ5rUPYQW6vVLTYbokNgug9xp4vOgh/ttJ2Xt2LhDnqgcmCXu/FMegv4pmq2JP1WE
         XbYGimaUjJv4m4wzt6JMzWrIIzKjipDLtnb8mbL3g1FKEDbjOONq5iieBRO9oQfd54uy
         q0QOg/WoFlvVmQZ5D2iwYTWcUa/7R2VYuCULuqLUBUTgYWUBCNAo8nIF985ryzWAh+w9
         pN5TU9fsr17/LXKBXOWcb7jT7TnlXEAQmfhkorvUzabCDSTQp2lzt24890VLedFrkPt/
         6dzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v26si6837895wmc.7.2019.04.04.09.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 09:23:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hC59a-0005f2-1o; Thu, 04 Apr 2019 18:23:50 +0200
Date: Thu, 4 Apr 2019 18:23:50 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Tycho Andersen <tycho@tycho.ws>
Cc: Andy Lutomirski <luto@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page
 fault
Message-ID: <20190404162349.rvkaozmtozamdoar@linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
 <20190404013956.GA3365@cisco>
 <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com>
 <20190404154727.GA14030@cisco>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190404154727.GA14030@cisco>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- stepping on del button while browsing though CCs.
On 2019-04-04 09:47:27 [-0600], Tycho Andersen wrote:
> > Hmm.  do_exit() isn't really meant to be "try your best to leave the
> > system somewhat usable without returning" -- it's a function that,
> > other than in OOPSes, is called from a well-defined state.  So I think
> > rewind_stack_do_exit() is probably a better spot.  But we need to
> > rewind the stack and *then* turn on IRQs, since we otherwise risk
> > exploding quite badly.
> 
> Ok, sounds good. I guess we can include something like this patch in
> the next series.

The tracing infrastructure probably doesn't know that the interrupts are
back on. Also if you were holding a spin lock then your preempt count
isn't 0 which means that might_sleep() will trigger a splat (in your
backtrace it was zero).

> Thanks,
> 
> Tycho
Sebastian

