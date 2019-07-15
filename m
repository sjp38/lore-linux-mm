Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44440C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1EBE20665
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:34:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V5CMHU9S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1EBE20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 957716B0007; Mon, 15 Jul 2019 06:34:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 907026B0008; Mon, 15 Jul 2019 06:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AB1E6B000A; Mon, 15 Jul 2019 06:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28B216B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:34:16 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b6so8689190wrp.21
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 03:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/tb2YFKotIun+RrxUFkUJ3SPYjEiIEB8yDIasy299tI=;
        b=uVWGd6W97uu7jTysS19uqLRet+13Xx5ED/7u9O+oSdVc6S6B9Tu7XI/M5Ld5F8Fivp
         65MXcVhFdoZP9DS44odDm1uK9Y/zcXjLfwh7h2zOsAT4X1dmJMUhckZjz1iN4hhPKhCr
         5XuiaO2+5I7nruCptq4kvA/KhFh0dkihW7J4nneyWm/sgnKdhPaXtDLIg2L03YlBUnjV
         KJJd6o4dnErpIfYZBuPAs9gzMR2zfDb3jqUCUpIPyXGa4TjCAUXdqSCut/mHU7bYD32T
         hmFgREyxN2Tsi9I2QIJFymaekj0FTXpltZBjzTg52SnXkoAyIbbaL369tl3Vopse3U17
         JYMQ==
X-Gm-Message-State: APjAAAV54zI/0EgbQp84DttRO39HTnDzeU3RuNQzbVNL1gjU4sKx0rDw
	wKrghxAq6y3Ggen5gRMZ2KEuTjZOybXe0+TFiTdqnw93FHV3MgUOC8Szzn1jp3PVXLiMpOvk9/E
	/q51+ckoFTiHKxriLxVbqAN+yNOSv9Kxtxq2FQLhba/fHkny+Z4YDe/85a+QdzYfHrQ==
X-Received: by 2002:adf:f888:: with SMTP id u8mr1117187wrp.238.1563186855693;
        Mon, 15 Jul 2019 03:34:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvguDDfhbHZMtjFfh2chadZ0U51R4kw11ZI1nZILLLdwJNqCo1kWV2N8nfadnCQEQayNyP
X-Received: by 2002:adf:f888:: with SMTP id u8mr1117057wrp.238.1563186854787;
        Mon, 15 Jul 2019 03:34:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563186854; cv=none;
        d=google.com; s=arc-20160816;
        b=Xie3mKeRjjTaHy62V/XCF0yU6j0mysItWXK7xhl2Kb8dEArWHOotN9VNwZ1zB6kG+W
         nzYhudgCbNBg+cGAob7Rb1Kjy/Np6U9TZQdmifz80iHWrrrInzu84sASwPw5oArqSfbs
         TDaHMepgeiioOB6El4XBI4sfzRGahaOupcEhI3PnLhDENbRp/nUVqxLW5+2ZAKYIRkc0
         PBS63FL2foNtAKRsiQo8o09zD6iTjNrKSiDMPTTJIQNq0qL8gGWkLB/7VYzGlwUMnvnw
         XQMU4QE5OTOROfv7shGrC0N9cuy4DBsNIhTjvj/R5EeTf+WrjQTP2oVfgklU8y4ff3Yp
         eb2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/tb2YFKotIun+RrxUFkUJ3SPYjEiIEB8yDIasy299tI=;
        b=eDuGQFIgUs0UtUCzLMfZYzE0Y405vNRK+a/9+SIatFaMAy2J+Sm4VcTwTMGstSFtJX
         f8+bYPFgbAmXDN7yq17rHaXlCKnPSfT0Szg7HZQGeQGe1TWYCud3J5hQMXrKt6Vk/30r
         eYiOS0xJ8Mwx9TERoNDZ7EP48Jv4r13BDltfWu2QmKBvjoQfFvPPaPFNALClNhYaOKrq
         kOIRNjSzFUGw64LOfNpehDWtPU61dz0AqoNcnZSw6ke1gC9XyCgKIIRLu78RpCkSJR8O
         viOWTkg0Wwm3kDJ28/1wP5cBxxoPegX0i7vdZYQkiZ/ZPRgMbjMHaTlAYmuI2Z4UOa0a
         ns3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V5CMHU9S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 7si3827816wms.56.2019.07.15.03.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 03:34:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=V5CMHU9S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/tb2YFKotIun+RrxUFkUJ3SPYjEiIEB8yDIasy299tI=; b=V5CMHU9SdBHFe0JHCPJ/DfQ9M
	whb9p82Se2ZevWYbvvkDuh9u+U8Uiaonxw43GBYwgQDNYEP3CSLvWClmBZIh3Lm+Ag21BXBcQk1Mb
	tgDnaHbBDgvqR/pGJQkjgPMBi8ydXL5TMB2U0D5aL+V/dJu7peXHwVcCgDtxjqnZvWk5TdtQ3tgPx
	IGTM4iWolBrZicJtBD0iROZpa0kB57IsFZqVCacCQtfX+9jji7DKttASvz4iWs+PWk4iVM7PXf/6Y
	Had9FeMPHZ0ajhZ94uJ2xDAy1FsLZzeKnZY3WncpD74MtSscMFXyqrGpbZ1cwCRW0KIHhvnq6mOlo
	gLv5bHwWA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hmyIt-0001jj-LI; Mon, 15 Jul 2019 10:33:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 01F3E20B29100; Mon, 15 Jul 2019 12:33:53 +0200 (CEST)
Date: Mon, 15 Jul 2019 12:33:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>, Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
	Jonathan Adams <jwadams@google.com>,
	Alexander Graf <graf@amazon.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190715103353.GC3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
 <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
 <20190712190620.GX3419@hirez.programming.kicks-ass.net>
 <CALCETrWcnJhtUsJ2nrwAqqgdbRrZG6FNLKY_T-WTETL6-B-C1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWcnJhtUsJ2nrwAqqgdbRrZG6FNLKY_T-WTETL6-B-C1g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 14, 2019 at 08:06:12AM -0700, Andy Lutomirski wrote:
> On Fri, Jul 12, 2019 at 12:06 PM Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > On Fri, Jul 12, 2019 at 06:37:47PM +0200, Alexandre Chartre wrote:
> > > On 7/12/19 5:16 PM, Thomas Gleixner wrote:
> >
> > > > Right. If we decide to expose more parts of the kernel mappings then that's
> > > > just adding more stuff to the existing user (PTI) map mechanics.
> > >
> > > If we expose more parts of the kernel mapping by adding them to the existing
> > > user (PTI) map, then we only control the mapping of kernel sensitive data but
> > > we don't control user mapping (with ASI, we exclude all user mappings).
> > >
> > > How would you control the mapping of userland sensitive data and exclude them
> > > from the user map? Would you have the application explicitly identify sensitive
> > > data (like Andy suggested with a /dev/xpfo device)?
> >
> > To what purpose do you want to exclude userspace from the kernel
> > mapping; that is, what are you mitigating against with that?
> 
> Mutually distrusting user/guest tenants.  Imagine an attack against a
> VM hosting provider (GCE, for example).  If the overall system is
> well-designed, the host kernel won't possess secrets that are
> important to the overall hosting network.  The interesting secrets are
> in the memory of other tenants running under the same host.  So, if we
> can mostly or completely avoid mapping one tenant's memory in the
> host, we reduce the amount of valuable information that could leak via
> a speculation (or wild read) attack to another tenant.
> 
> The practicality of such a scheme is obviously an open question.

Ah, ok. So it's some virt specific nonsense. I'll go on ignoring it then
;-)

