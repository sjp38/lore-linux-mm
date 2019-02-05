Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 789BDC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B2A20844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PoMhzwSc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B2A20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C50AC8E0088; Tue,  5 Feb 2019 08:30:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD5F58E001C; Tue,  5 Feb 2019 08:30:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9E308E0088; Tue,  5 Feb 2019 08:30:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE048E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 08:30:18 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t21so1187236wmt.3
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 05:30:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CVKHIuEvj5JGw+bPxiuecR8XPRMXnKXfH5LmqCODJr0=;
        b=KBmrHxlAxbpIQsoKi36aJwceJH6dJkZjht6/EA9TkpOiPVuzvtOp6Hvw24S+1RUyLV
         BgZBRnl5O61/FPPSG3LuIxXP/Gf2F6Czb1+w8o9qT/2sldynpQ/8OHUNH189b4CwmHv8
         bdChXuV2QifXDS2fgZkBPx0bj6WKpVLaRi4fHUcHFWGdOKHb4iMo/9yNu+lRnG5AseYc
         DrlOAfnItSMWj0R3U0PMXDrlGh2bc2XBACuqP50Dh2mNNxyuaISG7RvMcVMZatN4wwX5
         FI1N+BgLI+hu7GxQhtMPCwsP/CrXFdh1J4kBZJ+HPlSg4lGsI/L09HZogeyKQaLVxPZ/
         e3SA==
X-Gm-Message-State: AHQUAubPe8A7f5nlJ7WXyLmb+JJpJZpr+uk6Lhw+r5AGUcJKqrcRvp9E
	mpQD2iy5f6ioNmN0A3Mgr2BiQODszstZu87j/naROvOa81siUv89jcjf/gNAIq0y9f1NwaFrg6e
	xSQFwEhqLxriZqLWZdrpNG1eMCNKbKghyAcblLhQUvJz3OGLgvXdxoYaQl9eR0XEcsQ==
X-Received: by 2002:a1c:2003:: with SMTP id g3mr3739210wmg.32.1549373417777;
        Tue, 05 Feb 2019 05:30:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdYqsKDWe1i62HchjhYEohCquFHmjSzcs0/m94ni7PLAbMVRmnpNO7nYMYN3FYYyu++4o+
X-Received: by 2002:a1c:2003:: with SMTP id g3mr3739174wmg.32.1549373417008;
        Tue, 05 Feb 2019 05:30:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549373417; cv=none;
        d=google.com; s=arc-20160816;
        b=lYi348jVZMUK3/NtWfWxGQ1MM/oMnIy0S2Z02pNm/OecFHvi3CYEadLCKrIUMZqcWw
         WKXzLxMJ4IXGVBfGMPFvlVdiHv3eIVfGLRX87LbGWLFvUeYalzuEf1aT30jPkCPzDoNG
         3QFmP0HCdeygWlVmlPdbmoElnm7BzEvK+TaO0LPvnmrvEH2FFDvUaRzrviGsaDk4afkp
         9LDPfwzHvdw4nWaHZrWiuivkqn/OfAjtA7xgDVZmlj0cLmS93GYz3o2zcVaYzDmApGTf
         FKJJjQrKfUOOCNhNgFtoBQLoheTd9U8IfG+cB3nFWZLRTRT5ZZvwSBOmVv4gWMBM0La+
         u2/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CVKHIuEvj5JGw+bPxiuecR8XPRMXnKXfH5LmqCODJr0=;
        b=ixLWU+ApuffWhyZL1yIerOurLZoOE62ubfoABvtMA9c+ANQVkOsSvEphJ7CSARtyxi
         FMnPSJtvX6tROimnk+xx1ODPc3rH9M8WaSnJXFSN/1X+RKUwmrVPjfdAyiNMG8ww90hA
         6iW6GMtZvPKBN2h2IqhQkquUdeTOqDSvJhHCVCB/RRCagDd/yswbQ9vocJq3ax5JGbYq
         AYfgZY60cMZO79uLc5VS5/HCQ5CzIeDHTNGruKIcSVrFHehkkm5Uu6eFIu/iytZmzyYF
         0284hMpI9oXuA9TO0xPg4YjsawUj65dd6GZ6E3eqPrhSXeCIXAS20QqVYRfC4E0xSOTV
         cfkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PoMhzwSc;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e1si4749756wrd.58.2019.02.05.05.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 05:30:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PoMhzwSc;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CVKHIuEvj5JGw+bPxiuecR8XPRMXnKXfH5LmqCODJr0=; b=PoMhzwScDlbzVjbkRBMfS4MZr
	XfllCw3u9d26TcsNbDc093sC1RxuPXDZdQHSK2vTbLzwL0ojT3aZp0xe4o9jyt6A0d5fQOCSYHUih
	6CF3lbljAfVseZghqn6Pau0P5tXLAO6zQQcAGTTjRx862pUtQgZIEQwub/rYZPsmd6yqPnj0TGBVs
	ElzmBbTUGISW5G0NVPgVofxdS7/o1cgNo8R1wO/E43lLvGAy0Ljfc0lF85dD8t8x/RDAE29wcXiT0
	YTsQpytF2iY8zJOfEEnJwEpajF0ODa1Q2SMkWVJhldOFAkFR5r6YXvmenPbdZ7AVxX3z7cOOCcMxP
	ophLotiNQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gr0nT-00047L-1s; Tue, 05 Feb 2019 13:29:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C67B82029F1D6; Tue,  5 Feb 2019 14:29:53 +0100 (CET)
Date: Tue, 5 Feb 2019 14:29:53 +0100
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
Message-ID: <20190205132953.GF17582@hirez.programming.kicks-ass.net>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
 <20190205095853.GJ21801@zn.tnic>
 <20190205113146.GP17528@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205113146.GP17528@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 12:31:46PM +0100, Peter Zijlstra wrote:
> In general, text_poke() cannot fail:
> 
>  - suppose changing a single jump label requires poking multiple sites
>    (not uncommon), we fail halfway through and then have to undo the
>    first pokes, but those pokes fail again.
> 
>  - this then leaves us no way forward and no way back, we've got
>    inconsistent text state -> FAIL.

Note that this exact fail scenario still exists in the CPU hotplug code.
See kernel/cpu.c:cpuhp_thread_fun():

		/*
		 * If we fail on a rollback, we're up a creek without no
		 * paddle, no way forward, no way back. We loose, thanks for
		 * playing.
		 */
		WARN_ON_ONCE(st->rollback);

