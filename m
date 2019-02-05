Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29995C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:25:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D99282073D
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:25:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Pcx+6gkP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D99282073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D328E0083; Tue,  5 Feb 2019 08:25:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FC1A8E001C; Tue,  5 Feb 2019 08:25:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ECFA8E0083; Tue,  5 Feb 2019 08:25:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2F288E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 08:25:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 3so2549735pfn.16
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 05:25:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+l45x5l0P651QToTgntqm4C4rBuYwaWF/YbxeJcL2io=;
        b=XLhcSTT2cHw+mypBO12uxEPXJJYI0jQGImXHdg5ayOy6gQDXwH/vpiaN67j6Qh6pYK
         Yc5/SX2QFND3GW9k8WxAyWlBzvlykL8hmlPh9ZrN/31gGGe0qkcHNGdQnTOxF10UlnT3
         OQsfuFF8XrRiaMRHB0ItZmwjF+cycUvLxlKRFl9AExAzSw/G4Dk/mHtl7V+CL2e2jraX
         4gWs6jtBiUiqPv+LehRd2fI9M64oUiEgYgCNy0OX9pQcgH0nxwCUo1ZDkbJNCAX9vjLd
         rBghd4jH0Y892ntBooXew/IrnM/Z8+nBd6qAD+2Q1sQuI66glMHMaQkx3VLvW2jSEBj+
         qkHQ==
X-Gm-Message-State: AHQUAuZpL1DEEqhBvjqP8l6J8N+ZZ2meNPO8mFFY4NGZ8Dey/iOEEE2M
	Dce7aFvsVckBukdRLCspK/p0LFZhWvcfSPQZfwCR6QNk4GpNE9HxN24wj3ojYNNDfSxs9Z0m1ll
	x3yknCYv1yTPHA0C59Blu36yCdkHLP8F5kH45PQ5lpCrEc3sRP+9VkQKUgbwI1tZvPg==
X-Received: by 2002:a63:4456:: with SMTP id t22mr4677132pgk.0.1549373116498;
        Tue, 05 Feb 2019 05:25:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZAuObGDszEa53bTwwqv4LDZln1L8lb+MBMAP2afRhw2u7LwlcdDbQ3EktLngsEsZj++Rz8
X-Received: by 2002:a63:4456:: with SMTP id t22mr4677039pgk.0.1549373115213;
        Tue, 05 Feb 2019 05:25:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549373115; cv=none;
        d=google.com; s=arc-20160816;
        b=zjPLoeenHksYE92mOyWoLGTV7afEXxXGWAmnnlzcMzN2pytkCPoNQexLoFl8Ya9Z5a
         7vjLVsS8kL6bSCfN85mTI0avrdERDXfdBGZR7Y3W9cyEFsJtnVDEJS/kNiwHmVso53ra
         ccIPJz8bRNTD6UgtiqS9CvOrP4zaBIogJDaQ03CgW5v2wvuU5kWcffcfsLwLqhu2Fx0G
         YxumxEW6GB1w3U0QUzgEorbaBjXhdwuJOu+7pSKsoP4Et7jbuLyQXTHD37JYHwRifAaP
         laxQhQTtAnb8z7LVIAxEA1LyywRWfBFtsjXcPESmVwShtrGGYukcg5ghcRTRkTpFedLK
         XlnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+l45x5l0P651QToTgntqm4C4rBuYwaWF/YbxeJcL2io=;
        b=ZsiMpKsk17+dXNtFD+ClvAj7hdtau2ZkUHCZNsgS+1XyxaZrMCtOnX/3VPZ0U2HDwJ
         3C1pRg7PjjgcrbUVXa0peONvV5eA/OHkFsJCxL64COyfh0VbC/oV+dgsRkqIhFIdxhgN
         f7Lwf5wYW1FwiIre4x8yLJl/5W6j1klVL4a9cmi4p8unzseaKpvObC0zu/fEwwyNJrLX
         UsuwfHdZJJdssnBB9ypxLieKHqrK82LbOA5HLXbxiroOkb9Sq0qyUkEEfzgq0Rk6SlbC
         2hVO9ibSCCgej+wXr8dN115Bb3AxWwHNWMmLoGY20MlcMxRy8rXMvkg0I+aSG/c7EV63
         3rwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pcx+6gkP;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v184si2991118pgd.295.2019.02.05.05.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 05:25:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pcx+6gkP;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+l45x5l0P651QToTgntqm4C4rBuYwaWF/YbxeJcL2io=; b=Pcx+6gkPLdBa1ieyYGSrBM86W
	cluGsoVQzC2hMkhbRbBbvcd309s1CoJjgS8x3tyXcriGoNdWG4+Z1ApqrCrmflsbikjhAWgYdXLIm
	5VtZ84kTOXNSEEJCU2oPV7toJzb9bsmDs5sAWjqM/9HoDb8jZiKaeLe6fglkiNHCyBuxWFeOkbK3A
	MqMnbfWYhbM5bmqVdTmFDnW738MZR1o1akvR+72MWee5cFKjAdchbhuCAolzuUKVnpFfQ+4oEhHue
	DEEMlRNJwbJ2KT75VJf/XcinLApF6zKOOhzZLVaeryeSMnWmHf5w99bCrg1Auwa3uPU0l+nf3hNIW
	LIaeKvqPw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gr0ir-0006Jc-5O; Tue, 05 Feb 2019 13:25:09 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9EB66202A2A0F; Tue,  5 Feb 2019 14:25:07 +0100 (CET)
Date: Tue, 5 Feb 2019 14:25:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 06/20] x86/alternative: use temporary mm for text
 poking
Message-ID: <20190205132507.GS17528@hirez.programming.kicks-ass.net>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
 <20190205095853.GJ21801@zn.tnic>
 <20190205113146.GP17528@hirez.programming.kicks-ass.net>
 <20190205123533.GN21801@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205123533.GN21801@zn.tnic>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000036, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 01:35:33PM +0100, Borislav Petkov wrote:
> On Tue, Feb 05, 2019 at 12:31:46PM +0100, Peter Zijlstra wrote:
> > ...
> >
> > So while in general I agree with BUG_ON() being undesirable, I think
> > liberal sprinking in text_poke() is fine; you really _REALLY_ want this
> > to work or fail loudly. Text corruption is just painful.
> 
> Ok. It would be good to have the gist of this sentiment in a comment
> above it so that it is absolutely clear why we're doing it.
> 
> And since text_poke() can't fail, then it doesn't need a retval too.
> AFAICT, nothing is actually using it.

See patch 12, that removes the return value (after fixing the few users
that currently 'rely' on it).

