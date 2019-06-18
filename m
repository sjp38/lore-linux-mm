Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D4CC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DBE22085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:13:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uDQHwhGW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DBE22085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F4CA8E0003; Tue, 18 Jun 2019 05:13:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4F08E0001; Tue, 18 Jun 2019 05:13:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAF978E0003; Tue, 18 Jun 2019 05:13:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC718E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:13:05 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b14so5841073wrn.8
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:13:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DWxebD/lbygK+SpH9wnfp4x77thiB2bg6Ri9elX25UY=;
        b=Mx18WRkuUds+Q7uTov3IbNMMytXwwCfnbZev2lE/v+nR2FnnLZlKKUW4IWvbrzPdOq
         OBzurDAWjGOAla2Rj2BYHKPvynyuJf+u8BDBMVMOSpbBoXqNQtlYpA6xj5tpUFci0vdw
         1Ax19bOgqlAwYnrN57ejVuZ7bnibCkNm42N/5UTtvNpjV6QPm5VIv4aqAUSTRthqQK77
         GKrgORuBVPy5HF7W37OnLxphZ60ShZSKQHZYlugmdkTemlLTkEcuU8+C2Rxl5/HoHYyE
         TS+it9RVyknW4CuwdFzXRmClPy2Z6t6x8/sxbAe2IZxXDMf5z0uL/sJhCBT/8z4zkOo4
         P9HQ==
X-Gm-Message-State: APjAAAVGV8AeQkMIkDyMhdCLPP+WsTk9UK7AQHEE/6nyx2uJGuO7ELyA
	Z6Mvpm4aNNWRHMYlbql+4ypt8YXDxjsgAIIxfm48vrq3bubyOVvHNY/Vl/SgX2bhdbM8xo2G52V
	XbcbsoMkSb8aGx3hvfR/qe7PRgIlh+UuiD+ODKHezSSy7zMZoBUvGhoFlQyW5RnW19Q==
X-Received: by 2002:a1c:8a:: with SMTP id 132mr2541673wma.44.1560849185107;
        Tue, 18 Jun 2019 02:13:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTiM3QLPJF8FaJuR6c6OLnQ09S79eehp4Boi4U1myzEVNTNMNy9/l7VddnIsuETd2KiGbm
X-Received: by 2002:a1c:8a:: with SMTP id 132mr2541618wma.44.1560849184305;
        Tue, 18 Jun 2019 02:13:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560849184; cv=none;
        d=google.com; s=arc-20160816;
        b=YaqS6kgquy2MnvHQiUV5Iifoo0rjKOF0gwUaFfnjgEfHQMqx4JmffqrtJ7AbY9hq1L
         IpqdPNJF9QCghNIAvDLqn8SITHrH9d4xuxdHL9dSYqWcRW2PyzCmtT5ea4nJqampj9RV
         Mx9wM+7f3KXVI0v8FyIsnvLnQFsNpZq74JHmffbWWhPP9GL5M8Airxl4rbNI17JT/0YY
         56rnetuw4hVMyCabKaAsVDXvSmWhphrHvLZzHHU7ahzchmKZRj/fYcOxlm2T+gqxchuy
         cSWzOJyDKeP1EQc2A2SAvNfMHbgPxCu5EuZ/mKMKE8Z7Kua1Cn+qSCHM3udtGeiF9Q3K
         sU4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DWxebD/lbygK+SpH9wnfp4x77thiB2bg6Ri9elX25UY=;
        b=z/2iLTYF/LV5yF0f17jZNjX0JOvP8X2HnE8/VxGWtHOAgZHEMSJiRci6QHgnXC8RIB
         bsEtQe5Z8VdLHGpAxnWhe6w2EDYms1d3PFAwwyah+iCafvsQee5XbT8iE73Y5eVjHriW
         bmJSlIaQSgMnh5HZ5+VUHuXfpxVuBpgNSMK6DWIntkG9/ZcrT8Ify48zii5/SvIYL0rM
         HmpT/miR3WeB/xjXiTnocDjN3CGcuyYAr31vrQHQbnpa7s7I+MFPaleS0vcuxrmqpCKw
         I86ViynSHAc2tqGFq01SsxLzSxmrhRAGGCH2twKeDo+yeXlFL8Q4F4l3Kw/TUfxD5A5S
         zJIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=uDQHwhGW;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r76si1389167wme.40.2019.06.18.02.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 02:13:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=uDQHwhGW;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=DWxebD/lbygK+SpH9wnfp4x77thiB2bg6Ri9elX25UY=; b=uDQHwhGWJGqiGNlXRpc+k6mqb
	T/OhF+fKkE9yW/1WzX5e5PKNLbvQaIEV8hjfnN19Gcy2xbw/eGs9cmZhzSw8M/dic5nZDgqvtKokl
	Z6IMT2orRt1vL693hdvgisFLg0TYANLGdUAijz81Pu4wz3x0lSGQAtPaTZFsOA3d0MjysgSP50m5E
	+nJQ6NHn87W710nEgSyxyCcyTiUu4cDdwAom6SIAGU5SekK6vxRPBlyjW5sJFJL7Mkjzt7B4keKc9
	AEvw9JywQnLYrUBl+qghSJmrCZU8ZheGjH9rfN0/npezev7TcMgM94jN8FuanvHBJWWzT4IP6ikYK
	aDaVJhvRA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdAAZ-0000dX-Pu; Tue, 18 Jun 2019 09:12:48 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7778620A3C471; Tue, 18 Jun 2019 11:12:46 +0200 (CEST)
Date: Tue, 18 Jun 2019 11:12:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Kai Huang <kai.huang@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>, David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	Linux-MM <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
	keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190618091246.GM3436@hirez.programming.kicks-ass.net>
References: <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com>
 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
 <1560821746.5187.82.camel@linux.intel.com>
 <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
 <1560824611.5187.100.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560824611.5187.100.camel@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 02:23:31PM +1200, Kai Huang wrote:
> Assuming I am understanding the context correctly, yes from this perspective it seems having
> sys_encrypt is annoying, and having ENCRYPT_ME should be better. But Dave said "nobody is going to
> do what you suggest in the ptr1/ptr2 example"? 

You have to phrase that as: 'nobody who knows what he's doing is going
to do that', which leaves lots of people and fuzzers.

Murphy states that if it is possible, someone _will_ do it. And this
being something that causes severe data corruption on persistent
storage,...

