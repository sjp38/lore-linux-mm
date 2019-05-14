Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E11AC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 214F42086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TyVPLD0S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 214F42086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31896B0007; Tue, 14 May 2019 03:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E1CB6B0008; Tue, 14 May 2019 03:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CF276B000A; Tue, 14 May 2019 03:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBA16B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:37:49 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id d140so1755123itc.2
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6IoQ7/a9IdkQHn1Z/AXbPyDzwjbmRx3DkVjFwe9CEr4=;
        b=WGpXeA/bRV2a3gomKXFgfvzBCR0CCpPUwkGUFcxxWQ8hvtLxFLHjtRDCY14UrMdg4W
         ctUaW/yqCtl6i0et24HLRTumSoh6nvnn22ESJPzJ7v4GFDX+JpkH+HkMpCaYt1xJ0m/+
         +MdL+I1nM1ptVlF7DAXpvM795dLHYrn281MkEwF2ad6UBQFgk4Y+LAgSCGppM36lQFPb
         UxDfq2GwYbjV6csv10sMSUVsw7uVCzk53z1e/bxdn+LzoVC2RWTZ8EQu5J5Kt6NirgG2
         fnxO2x3MDl9Ca5Adf2lj+nkmLiu5eBBgCf8OrCCYhp4yl/FU8BpK7Y5hluLSVM4KW/Fd
         i5SQ==
X-Gm-Message-State: APjAAAV8xPPESCKgkPu4t1VmzRwmGZJoeFdlupWf2Mw8/RhcddMCAUEQ
	nyvAlJ8q+1NXnu/fzB9UHMasGDq2lfyp2ulG8OZpzT+FWCn3rzzbXbsrCdszEemDV4DT8VM9fH0
	59/14kXNyOh4geVPnyfJwmj/BwLCSdmsU7uQ2NO3t3BPRVU1g+yXZkr3qTdTvGxCeUg==
X-Received: by 2002:a6b:a0d:: with SMTP id z13mr2628196ioi.67.1557819469207;
        Tue, 14 May 2019 00:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTtUnUl6altQSiQIDWULf0Kf3MHeimqjLM8S1A6bNOnfGD5s7vkssaj9MSqGEV7aUirOt1
X-Received: by 2002:a6b:a0d:: with SMTP id z13mr2628173ioi.67.1557819468569;
        Tue, 14 May 2019 00:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557819468; cv=none;
        d=google.com; s=arc-20160816;
        b=H74lh5EQ1Pzpp9ZSmWZ9Tl28RMZGlHfDoro3O8tvbBakrIRHDIU3IfEYWS52My3zuf
         2UpWMqJ6cVUH5vRjyUWcclcGMqfZTaGvOJevvMhCZ/7pGo4ZQaYRpP41BizWAp123bKF
         ZKMQSp0WWH+zexRkz54CUUFIsZJufjn6JkpiW1bwATJmEJSRMkvm54hpcaI8EIoWhd98
         op4bXEES4AYCb9Es69Kf9mwpVxhDCoJTxYyRoV0idORDVETuDzW2dCmMav22R1d9prLK
         RsT1/+jtjL5CHgTxt7D20KCAyzWD110BbpejMUiEYTkSJATbmtjZJy6yQe9zp0Z43xqH
         SNVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6IoQ7/a9IdkQHn1Z/AXbPyDzwjbmRx3DkVjFwe9CEr4=;
        b=kd5FG1U4wKgj1k9KWW3dGUwSistF7ZOf7DuEZBhDthn8RXz6Ti/03ybia8UsaIW7p6
         0L9+0dnBrBMzMV0bTm8RXDiH5WyyR7rMrkpfN125XeP/lqTtJAu56pn7/qd8l0bO1Gu/
         EgbSXvIB733uUTjWIWWiuz7nGxUtifR5aczlJIsr/OFHz33VkHbCOhjA5YIc4q07GAF7
         UNCNNbV4CinENPIGgclO++Dj9ZszakBIQoZIJlrFzpsRpxUAGzVYA/AuryxOAidLTjhN
         OAFa9PPR5uCyDGK8Tb45AC1jLnX+gbOSlOhrSGQteK1pDlc4JdZfqL5oqz4GrZHiQZEz
         SF7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TyVPLD0S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b3si1107680itc.120.2019.05.14.00.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 00:37:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TyVPLD0S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6IoQ7/a9IdkQHn1Z/AXbPyDzwjbmRx3DkVjFwe9CEr4=; b=TyVPLD0SuH8xFWcuuRZSwo1sP
	8NH2oliCz6k+CkUA52kcYMXTQ7tI1VjhC7hYfxAFEAH2MZYgF66I00OTKLwbnA9zwoeDr5xf9yTAp
	EB8PrSa5tGh8JoV74QlruaIt827d4iHtIW8J6WUsCK0Js9irNEkaPSitW+rKhkYW7Ph6gqY84ach0
	IYB0PN/E40HNVyTr7RZAcMu6LsLDAvaMI0S7UEbZPM9hfVJA6z8GKpaAineuy0Mt32gHv13QBjAAC
	4kegUb2GuuJ6eO898xWcEwLFAS+STD4il34l65Pi3sp3p3fydhRKrA1qfUa83YvW9MSN5VVbJiTzN
	humsLFLew==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQS0K-0006Br-11; Tue, 14 May 2019 07:37:40 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 8818D2029F87A; Tue, 14 May 2019 09:37:38 +0200 (CEST)
Date: Tue, 14 May 2019 09:37:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Liran Alon <liran.alon@oracle.com>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
Message-ID: <20190514073738.GH2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
 <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 07:07:36PM -0700, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 2:09 PM Liran Alon <liran.alon@oracle.com> wrote:

> > The hope is that the very vast majority of #VMExit handlers will be
> > able to completely run without requiring to switch to full address
> > space. Therefore, avoiding the performance hit of (2).

> > However, for the very few #VMExits that does require to run in full
> > kernel address space, we must first kick the sibling hyperthread
> > outside of guest and only then switch to full kernel address space
> > and only once all hyperthreads return to KVM address space, then
> > allow then to enter into guest.
> 
> What exactly does "kick" mean in this context?  It sounds like you're
> going to need to be able to kick sibling VMs from extremely atomic
> contexts like NMI and MCE.

Yeah, doing the full synchronous thing from NMI/MCE context sounds
exceedingly dodgy, howver..

Realistically they only need to send an IPI to the other sibling; they
don't need to wait for the VMExit to complete or anything else.

And that is something we can do from NMI context -- with a bit of care.
See also arch_irq_work_raise(); specifically we need to ensure we leave
the APIC in an idle state, such that if we interrupted an APIC sequence
it will not suddenly fail/violate the APIC write/state etc.

