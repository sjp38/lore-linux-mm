Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41175C282CC
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:35:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F400B20844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:35:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="DRBpNRi/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F400B20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96A768E0087; Tue,  5 Feb 2019 07:35:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 919008E0083; Tue,  5 Feb 2019 07:35:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8303B8E0087; Tue,  5 Feb 2019 07:35:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDB08E0083
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 07:35:41 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id z18so1079466wrh.19
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 04:35:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qy0tAhFBRu2LNdPFTbVIGZuXfaj4t8RKzaRmpgJF9M0=;
        b=VhZ+0NaXBMi6NIeTBwGu3pbpFMwREVoaStlAVw/0sD5Ye4YCGFX6QH6GyvMWBM3iz4
         dOTGzv8XtjnUw5SDba3P4T3VCiZ7c15EoTphsPck8VRSHnLKVssfsX3HI6Y3si+0ylfE
         B/GZR2eBYa18g3zklqZfd0cq0/oSMDlJAwH5ygby3UUrbzLd6yvDz+qwiZ2EvqzGbMiW
         slOFQC1hnIqwXSh7MCUbivxmMWhmkxPlF7Ogis1Acmex723eRFHOUewAdzNoPYoHG7UR
         ifst3vuIzU2iZfRtyXBQQy5PryQIGb7lqjVGezgjTqPh9PFF7DmRmR8oNPNg3PU1Brwp
         2wQQ==
X-Gm-Message-State: AHQUAuZY9m5nOkQZKv3AXtDcE7NLjX3hvXVIrpZdedwrK99BC0p0JYtJ
	BpHZtJH9WXlDmB2kzbifcj8A9RVOx7mVN2OeS97TB0l6d+aogkcDw/5E9ASAR+hf9XNK5nk5Xsu
	SbOSR/2fxvtEBc37WnPVKfzfqExKU3xY/2rAhkfUOQzCY0SdZw7dNsKFCsMuD/9Dstg==
X-Received: by 2002:a1c:35ca:: with SMTP id c193mr3531015wma.146.1549370140735;
        Tue, 05 Feb 2019 04:35:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYj2CiBUasBZlgj2Tq1DQdieD1PTQtLlPKqlUXfJY2Pk4iyBdQIveb7IGoA5sgpfegNkHCU
X-Received: by 2002:a1c:35ca:: with SMTP id c193mr3530965wma.146.1549370139874;
        Tue, 05 Feb 2019 04:35:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549370139; cv=none;
        d=google.com; s=arc-20160816;
        b=CeYsjLy6dyyG+1x2hPqAJZTawVB1fmBIWYWgJQ8hTHTfevlHIoC1FfkFOBualDEudx
         OIoj7r8q3kqFh+ksb0HKUwKn404D4QyHFV/9F1v2h2p8KSHFjab9tAyjRxGSj1gc2BRN
         idklg5E/eC4UBjFStpjaU4QM9YLWZ/RhERjCY7VpE3vuaLtuHLJ9d+le73VcZmU7hSrP
         o9VgCK9J/YAeGGpZLu1C79zSDSk42F0tnL5YDcltMGgz16fOB7vss0XfMdjApqSRSSe4
         jDQ9+YID6AocP/Ul1aGtf8If0g8X8CVXxCQt0Su1IyYVkZ6w+N4KRcwsa53VZbvhP2+9
         vOGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qy0tAhFBRu2LNdPFTbVIGZuXfaj4t8RKzaRmpgJF9M0=;
        b=HUW+mqlfpz665nRushs2Cruk/ZdU6fyMG+ww8wl0NCDXhdWTP8tOGpkhPTyq91zsnx
         L1p3fvnN0MUiTwMIiuOS5q/00aeDLL6hGoHj0CT7Ydz/Kt7A88DXqYSlMZ2bBEG5IUBz
         6xdAaIvTi9Ld2ZaDj4d3CtmJ43/c/nk13pT6dbc8STsDhSS5e0DsIA+0ukzDCSPzwEwE
         v6uoaXMnzVY9GIfdzaKBfX7fV0Y6d+3aKjsQ3w35n1pDR0SD2zUfw3cYyU2nYZvxB3rQ
         I371mreOknu6W1Z8mUrVbEIOFi12X7SrG2+5xpSlppL0ygw5CJXDp46wqz0dfjk03HLZ
         svxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="DRBpNRi/";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id l14si13623068wrm.131.2019.02.05.04.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 04:35:39 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b="DRBpNRi/";
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB6B00551F5C4602011D50.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:6b00:551f:5c46:201:1d50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id F06221EC02AE;
	Tue,  5 Feb 2019 13:35:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549370139;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=qy0tAhFBRu2LNdPFTbVIGZuXfaj4t8RKzaRmpgJF9M0=;
	b=DRBpNRi/AE/ddp/N7PrPG+UELrdIUTt+dE0vNyWk0LmyVCMEV87pZqiHROizDHuJ+chxOY
	wbn2bNksDewsX0nnPJonclKBTBPDLlbqaAPJQfBgIqfugNE/JGPoeg3HX/yPwElmarfcka
	AkZNyj+mTvYwgUo4/GGLwq7WnhR/PHo=
Date: Tue, 5 Feb 2019 13:35:33 +0100
From: Borislav Petkov <bp@alien8.de>
To: Peter Zijlstra <peterz@infradead.org>
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
Message-ID: <20190205123533.GN21801@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
 <20190205095853.GJ21801@zn.tnic>
 <20190205113146.GP17528@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190205113146.GP17528@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004625, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 12:31:46PM +0100, Peter Zijlstra wrote:
> ...
>
> So while in general I agree with BUG_ON() being undesirable, I think
> liberal sprinking in text_poke() is fine; you really _REALLY_ want this
> to work or fail loudly. Text corruption is just painful.

Ok. It would be good to have the gist of this sentiment in a comment
above it so that it is absolutely clear why we're doing it.

And since text_poke() can't fail, then it doesn't need a retval too.
AFAICT, nothing is actually using it.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

