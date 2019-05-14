Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 931F7C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48CEE2084A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:05:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jmPpBeXU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48CEE2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8EA46B0005; Tue, 14 May 2019 13:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3FC96B0006; Tue, 14 May 2019 13:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2E6D6B0007; Tue, 14 May 2019 13:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0256B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 13:05:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c7so12320176pfp.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 10:05:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KlbgFAVXgBXigN146B3nlFdjOxF2TXPML68s5DT9K4M=;
        b=cBmqAnBWmhj/jDHui5iMVxxkAlwqh0vvMtQgirHbVG3GGZoqlv4BT+pr42GsmVhURU
         nAZAdPTYRyG9yCj7pZo7E+zizzUdpJMp/QjFqUs1d+/QUfsQWSIVSWS5YhYq/oc6TZik
         kBeitfAEYBGM3Ot2O455Dg9nGKggzWFrtvRetdZgp9/9/gY3P4sPJ8+HpdoJQ1W+cchx
         F7rXv86yeH3ZZmPqjf7zW/2iLqIXZWIvKXjRzo67B7dmsmP8TFmKQIqn8U1DOCwZu+ma
         i2zSjnItgP5GPLPriyLO64CgSxtJL90woRfJXEiCxUSjLklduV+3cPwyuaj3++7Sgw77
         GJwQ==
X-Gm-Message-State: APjAAAUiUhp9cfGaHgttzcHRSH3+FwMkbQ2ZRKJeDp2uzkOBUxhQCKwY
	ltQUOruk83jXE8HMhP4IyzSzwWOLIwj34g7OVMEECfGtgpaZcp4G8PIGuHWDYaPFE8FYaj5me97
	hLP4P2lpcCKrjdeeIaiStg92bDMWX5CmDJoUXvC2Ox6LKWH7FH1MNtAkM59lTmE4dTA==
X-Received: by 2002:a63:2b96:: with SMTP id r144mr24341838pgr.314.1557853530096;
        Tue, 14 May 2019 10:05:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5XFTBjU2XQO3UH+MPgTVFlHXYK3EwvAzRWW8EOPpfgZ3IxycrNCpuGaDYPsDQJo5Z83sQ
X-Received: by 2002:a63:2b96:: with SMTP id r144mr24341693pgr.314.1557853528649;
        Tue, 14 May 2019 10:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557853528; cv=none;
        d=google.com; s=arc-20160816;
        b=z372bxLqt4klF8+6EI9N3vig+WQtPB/SBnm1x12Not4gPoMVA/ukSZeLFcdWPYEXQ/
         35rWdgh5KAr5zLEarXLencyr3LD08w1rl9fRABug3H9XHSvKILUMAU4RvEbbANbe/bcu
         9+CG3xQM5SRaLCqC+mDVtWupDzdL0lZLu16e+6aUNPumaxXsBRNdcM3tH6YUycQ053cv
         XCbs6Y6YV/MpKdPbJ4aFqFodr+dkdEoaUzv6QuxXaV6Y553y7pwOy5+t0XWd/wLL8gbN
         fVWhJ7L9bUfc81VmQUuF6nMmTrOTwFyni+KChw+cxJypBf13to4oL3YpVdRPk7ePPImm
         hjRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KlbgFAVXgBXigN146B3nlFdjOxF2TXPML68s5DT9K4M=;
        b=ipzh+LJskFTrWufZB+bzg8gzw/1SKA3ZE1ItyzYSvgILS/0mgcS8HDYV8nOsoYTI37
         RS9rtRtrOeCu7UtKEFQrqfbBrB3SSYvd6LwIf5rziHJis55oWbDvHQ8BNdYgQhR1c/dy
         EZjj2Hs9Ho2IwMbSUJTR2DajekPPJKYzWGJ0TNGuz9eDlMNnB1k9qcr2iq4s9DjpzVok
         kzgA5g3z72jlqzkyx9WiS0p4LwM32eELM8cYWwee2wnDT6q+EibXYxJdWQGEnbBaL4Kn
         W2BCMbE++ZYsNZt8mjYGQsVA6tIIMl//SVPfrvGHqfi0GlogwoHPGKV0Pc9wIl8dAhne
         RjJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jmPpBeXU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d21si20184320pgv.353.2019.05.14.10.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 10:05:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jmPpBeXU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KlbgFAVXgBXigN146B3nlFdjOxF2TXPML68s5DT9K4M=; b=jmPpBeXUM05r6s4bzTOSf6IqR
	+gcxkAlmEIZHWVOGUSv2eKJST1OuQS90zya54qlP9PNVULIwibJlblBwZsXAe2Tw9v0vEg7MjiaM/
	boWCqM4HmbVadcMDA2prEGa3avhoxYuF2vh3xSdRIHCKv6faoneacq3v8ilnKkxoDdFTuTgPbsDuT
	uLEdi9/F+FBWIQlm1a1dv6w5TIgPFvJ8BPFmU5wT6QPVgtTBJ1vdYZpeSo4AAqT0EWeUhZDUEIjFO
	FrcTQwOxOHFzl5NUcBxEpfOaWiTDtXCsTRjQU4nGpWW7HpkKES1Iudvt4IdtGHjcxL1Q9sWZFMh2Z
	b4JKSdzYg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQark-0000lD-Qy; Tue, 14 May 2019 17:05:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D00982029F888; Tue, 14 May 2019 19:05:22 +0200 (CEST)
Date: Tue, 14 May 2019 19:05:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
	Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
Message-ID: <20190514170522.GW2623@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
 <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
 <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 06:24:48PM +0200, Alexandre Chartre wrote:
> On 5/14/19 5:23 PM, Andy Lutomirski wrote:

> > How important is the ability to enable IRQs while running with the KVM
> > page tables?
> > 
> 
> I can't say, I would need to check but we probably need IRQs at least for
> some timers. Sounds like you would really prefer IRQs to be disabled.
> 

I think what amluto is getting at, is:

again:
	local_irq_disable();
	switch_to_kvm_mm();
	/* do very little -- (A) */
	VMEnter()

		/* runs as guest */

	/* IRQ happens */
	WMExit()
	/* inspect exit raisin */
	if (/* IRQ pending */) {
		switch_from_kvm_mm();
		local_irq_restore();
		goto again;
	}


but I don't know anything about VMX/SVM at all, so the above might not
be feasible, specifically I read something about how VMX allows NMIs
where SVM did not somewhere around (A) -- or something like that,
earlier in this thread.

