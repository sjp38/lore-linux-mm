Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 906A6C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:48:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD34206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:48:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD34206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F10176B0003; Mon, 15 Jul 2019 14:48:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98EB6B0005; Mon, 15 Jul 2019 14:48:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D611E6B0006; Mon, 15 Jul 2019 14:48:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD556B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:48:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f16so9258323wrw.5
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:48:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=AlErFgaCkIk9WeuYLBdUwSXBhj1jEiE0rcLIcYhJhQI=;
        b=lwH7rTeLXC54gw/rPuNgMrHUcjPFHKsTnsl9yS5AXkEvhfvIpDZADUQCZQZThozVik
         pZQ473NmdEZ0UFwv+EX7y+OsN6pK8CASj1FZ/KxmAQtjuBHstT0A7fhH5ODilmAsE7vr
         v3Ke0eAHfwxrWsOPCwjPsbS1/ln9Lb1Igxen1UAncI7dSRe5vNoEfYyyMXH5GLEHugv9
         XDmYUAJTRbSzlko3A/oO6P4DtUDYKEc62NhFEx/X7/xT5Awh/d7WlgbaUSjLXXy+Us1U
         lV6J6BbyclpGSmvHmGUKctAXpNVJmA+OKX5XZlLZww9oXQPEAhl6AHI9AR1qhBODh63j
         SmSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXvmdzol1R6GESJwCI6wjaAVUIk6/TtcEHX3JEPlAD6dZD8Ghuv
	ITOw+1YyeLA90Z/HWrMvrlyH7JevFS4XPXOIVlM4pwqa3XaF8nTlscgSZOweJdntInkQqFs9WF+
	Q/5hjt8HPdi6kPiGaSX5zIcgcJsrS/kAWfitY/3GsSpNwOnUY79GpsdL5HWXxyddi4A==
X-Received: by 2002:a7b:c383:: with SMTP id s3mr20111722wmj.44.1563216511881;
        Mon, 15 Jul 2019 11:48:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBxjWGmfWD6jISQr3HMng0EM0S+1uqiceUUxeuddGiixnFZeljkAPZcjPmnEy9L5hADGgU
X-Received: by 2002:a7b:c383:: with SMTP id s3mr20111688wmj.44.1563216511122;
        Mon, 15 Jul 2019 11:48:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563216511; cv=none;
        d=google.com; s=arc-20160816;
        b=lAPPKNmG21avIV69L4SiaL4v5HQXhFtD49SmiZ8/wfbOGC3InJxx4L4CeQPKJyjsfI
         o6bXYdkEyYvbOaicWQZYBTskIepLTR+HVPCgtRBdMR5Hm8kuQ8UY7IVX5Qbsf8AjsAtW
         DjJUrwyvnX4CKFQfkZrKQ5sD3Zi4xJ/Sik7BJX7ejeYx2K7eH+BRc6tUoX/WYg7Ot9CY
         mYgkMbETTFwT8CSe4veUbEAoCbAaYBHkPiSCJ67tcoKmL0hWNDJBx7V61c84t5TJRntD
         ST1kfXOT6K0SOl1d29vhsV5uBfU53iosJfLmuKs3okMhh58BN3buY55udvl7Gmh3gFsW
         3tKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=AlErFgaCkIk9WeuYLBdUwSXBhj1jEiE0rcLIcYhJhQI=;
        b=rOIqmgjicjnAFiFY+bZjWlsk7xgiLMsg4DbRzt566IPzF7IvGglc0EhxbhHG4pMJZG
         kEW3gf+rdUc1pZDXhFKUSxae2X6YmIp/9GHp19gCLGV+aX0NJmVEdZyJhMms/ktLgwhd
         IZweGe4zzkaVJxSNnu0Sh5cKAymAq/mKDx1CYKL/rPW7eJ9lp/rHO0UJIXocysEw6+A8
         90aTfc5IAdGPUyYSGxy0wrXhX+rhCG32r+JiB0qF/TMe/NqzsP0W4XKuCtcJm9mQ3/3z
         Au7Wi/5Lmr/MckfyVC+mlY/5KSzUEzXo5Tq+f6Cvke3tRBFG7JgJNG6AZiJD9GoMAaoP
         3t0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id b3si17585791wrn.401.2019.07.15.11.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 11:48:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hn61P-00044x-FA; Mon, 15 Jul 2019 20:48:23 +0200
Date: Mon, 15 Jul 2019 20:48:22 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <jroedel@suse.de>
cc: Joerg Roedel <joro@8bytes.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH 1/3] x86/mm: Check for pfn instead of page in
 vmalloc_sync_one()
In-Reply-To: <20190715154418.GA13091@suse.de>
Message-ID: <alpine.DEB.2.21.1907152047550.1767@nanos.tec.linutronix.de>
References: <20190715110212.18617-1-joro@8bytes.org> <20190715110212.18617-2-joro@8bytes.org> <alpine.DEB.2.21.1907151508210.1722@nanos.tec.linutronix.de> <20190715154418.GA13091@suse.de>
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

On Mon, 15 Jul 2019, Joerg Roedel wrote:
> On Mon, Jul 15, 2019 at 03:08:42PM +0200, Thomas Gleixner wrote:
> > On Mon, 15 Jul 2019, Joerg Roedel wrote:
> > 
> > > From: Joerg Roedel <jroedel@suse.de>
> > > 
> > > Do not require a struct page for the mapped memory location
> > > because it might not exist. This can happen when an
> > > ioremapped region is mapped with 2MB pages.
> > > 
> > > Signed-off-by: Joerg Roedel <jroedel@suse.de>
> > 
> > Lacks a Fixes tag, hmm?
> 
> Yeah, right, the question is, which commit to put in there. The problem
> results from two changes:
> 
> 	1) Introduction of !SHARED_KERNEL_PMD path in x86-32. In itself
> 	   this is not a problem, and the path was only enabled for
> 	   Xen-PV.
> 
> 	2) Huge IORemapings which use the PMD level. Also not a problem
> 	   by itself, but together with !SHARED_KERNEL_PMD problematic
> 	   because it requires to sync the PMD entries between all
> 	   page-tables, and that was not implemented.
> 
> Before PTI-x32 was merged this problem did not show up, maybe because
> the 32-bit Xen-PV users did not trigger it. But with PTI-x32 all PAE
> users run with !SHARED_KERNEL_PMD and the problem popped up.
> 
> For the last patch I put the PTI-x32 enablement commit in the fixes tag,
> because that was the one that showed up during bisection. But more
> correct would probably be
> 
> 	5d72b4fba40e ('x86, mm: support huge I/O mapping capability I/F')

Looks about right.

Thanks,

	tglx

