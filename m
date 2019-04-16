Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43FD4C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02663205ED
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:33:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02663205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 917DC6B0269; Tue, 16 Apr 2019 19:33:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C7246B026A; Tue, 16 Apr 2019 19:33:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DDBB6B026B; Tue, 16 Apr 2019 19:33:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 458B26B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:33:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so14266391pll.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:33:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=80mkIEPjFX3GofvQXpXAFS7npK0kEw5we8eApTx72F4=;
        b=nWgvg6j9S+yg014I55KKCqO9iXd88Zg/rT/Yqutq7Nx7gFCkUmg1jMdcScMb2WHPYO
         ZgDIZhr+boI2EKB9TLiK0PhPvWo9AoLbs1Shle8Uvyb4cgeZQD0fPVACpGnW7jJZJ+WO
         CiPXCOampXkU3F3Mjidi9Z9Xl88LCdFeicgwiZICwW3qUHx/qwlFAWNte5v6frY9tWtY
         pfAiYljUnZqAboShcBlQtc5jTqoa53v8t0VUHhdkAEY+cpeziE3VUWMQtDSiYJ8/m7Wr
         boEhf1jceobL7O8f8YxMlVqjy1BUE3yF/ABO3+PcI4PvkhwbxUa9IaHEXTGINEsEyX6D
         +N1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAW8rm2jlZwcvvzOFoybU1Wlz7qJAPCRmUBKEcukBqENjEwK9eKP
	F3djtsgG3LiS+iJV7rg2TJykBWgnSJcr5oe/y0mTze/qRQrY/ZdpzGh3/K3/JRPFfZVvY9fd4VU
	1QriItehLhvfELfR4WL5mKh3yVAybcmeY9J9+2WJVFJAU3qYG9NgdKcbE17INCB7ruw==
X-Received: by 2002:a62:12c9:: with SMTP id 70mr86667731pfs.156.1555457633946;
        Tue, 16 Apr 2019 16:33:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfQj3Sn4/2SJwPfeUhCHBsNx3VzJO+zmoP3+8XoZNT8gQJ479oV7QBdDim1pTrjS5k7NbP
X-Received: by 2002:a62:12c9:: with SMTP id 70mr86667674pfs.156.1555457633205;
        Tue, 16 Apr 2019 16:33:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555457633; cv=none;
        d=google.com; s=arc-20160816;
        b=gZpJ7BhiZ9et3yhgK60QwlgC6LWTLBhSQYsnMflrLRM857FA2DfNk3xPXb3a23smqU
         VX1AaRfwfxjZijqoSyQjRyXwEtBmvDRBNx4yoVzLX4thHmCPwNpQZxaakhT6VfG8HGZ1
         fTkTP+vhdfg2awS1jsDfl1pkf1athcr8TZcBkv/AfD2VgsXLIRyajfFVf8memiVXHrkY
         +zoVF4UQGnQRtatA430oUQIFNuW+3ek4y+o/AsKrAfLUbub1x/q8A/yfqGrMed4p/WgV
         6fxbJsfF9s5zKMMgsKoxVV9FRKzO6umsaLO/hbNF1JzFTlWZioKEn1Nqbs2K0Pg1ivA8
         z2dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=80mkIEPjFX3GofvQXpXAFS7npK0kEw5we8eApTx72F4=;
        b=PDDi1VA5B915X1/vcWogKsOWebzxGhFR62VXYPIOxmXfSB0MpY6QAMqD7b33UhGUDi
         V16vPj4aEfiaawjxv+7kzUeZD2iBN33wyq7M30Sp9yd1UMomvEKu3gNFex1tG2+hMeBn
         z1q4iHpfXo5XXVC6xuUFg63Tug8iHX5RvhLtOZAyAC5iSt7g68ymkWepnFIs+h0CrRAs
         iaigzvSMXvdJo1eswB6SLdJUEJq+UqpDHirqBYYOmIPK3PB7xAwAMPuMWsS7VEdAKAdN
         JK97BiwWiPIksg+U5Asa7O3MLoV9K4OhZFyO+cSY8pPwPEjUU9ktW/9PyVM9Q4ZtVQ4S
         uNqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y13si49370365plp.238.2019.04.16.16.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:33:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 5A7E4C9F;
	Tue, 16 Apr 2019 23:33:52 +0000 (UTC)
Date: Tue, 16 Apr 2019 16:33:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Alexey Kardashevskiy
 <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>, Alex Williamson
 <alex.williamson@redhat.com>, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Christoph Lameter <cl@linux.com>, Davidlohr
 Bueso <dave@stgolabs.net>, Michael Ellerman <mpe@ellerman.id.au>, Moritz
 Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>, Wu Hao
 <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
 kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-Id: <20190416163351.5e4e075ddfad0677239fc23a@linux-foundation.org>
In-Reply-To: <20190411202807.q2fge33uoduhtehq@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
	<20190402204158.27582-2-daniel.m.jordan@oracle.com>
	<614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
	<20190411095543.GA55197@lakrids.cambridge.arm.com>
	<20190411202807.q2fge33uoduhtehq@ca-dmjordan1.us.oracle.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Apr 2019 16:28:07 -0400 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> On Thu, Apr 11, 2019 at 10:55:43AM +0100, Mark Rutland wrote:
> > On Thu, Apr 11, 2019 at 02:22:23PM +1000, Alexey Kardashevskiy wrote:
> > > On 03/04/2019 07:41, Daniel Jordan wrote:
> > 
> > > > -	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
> > > > +	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
> > > >  		incr ? '+' : '-', npages << PAGE_SHIFT,
> > > > -		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
> > > > -		ret ? "- exceeded" : "");
> > > > +		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
> > > > +		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
> > > 
> > > 
> > > 
> > > atomic64_read() returns "long" which matches "%ld", why this change (and
> > > similar below)? You did not do this in the two pr_debug()s above anyway.
> > 
> > Unfortunately, architectures return inconsistent types for atomic64 ops.
> > 
> > Some return long (e..g. powerpc), some return long long (e.g. arc), and
> > some return s64 (e.g. x86).
> 
> Yes, Mark said it all, I'm just chiming in to confirm that's why I added the
> cast.
> 
> Btw, thanks for doing this, Mark.

What's the status of this patchset, btw?

I have a note here that
powerpc-mmu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch is to be
updated.

