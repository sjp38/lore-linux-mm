Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4CAEC46460
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:13:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BC3F217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:13:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nLpAdWEL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BC3F217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E52F6B0003; Tue, 21 May 2019 05:13:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16F266B0005; Tue, 21 May 2019 05:13:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00F536B0006; Tue, 21 May 2019 05:13:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5A3B6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:13:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b24so11750141pgh.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:13:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FtiVzriB2PhlcNAnz836XBuHzMztzkTorf7MJccM2OU=;
        b=FPZfdRV5ZTZjPrCARCGSALgwddVAFwkcVJJgK25Nu1LzD8j6hQG9pG7Z7NHEqq63aG
         AEj/Jw+mz8QQA1Lej5CGyJ27jNxAfVj5fe57GWkjftrSiOcpYx7CUDgVC01LrL6b11Vy
         NcbekbW7YGE4pXSinUktQFE7zB4UWKqC4CdI7uHA+U0IvrLw7vl4vwbOhFozqYgVbjWY
         KXiQsHgH3/bxfvtLwDbN8EwCAX/Kilc7w54hcpqJXhWi3C8L81jhm91IRCwEqKLFmntK
         sTi+qS7Ct+GCDt6m/2f/aGB0AEgeypnHsG6I/EStVW6gB3MjaILgbWidXnYoWk8QjrO6
         MBfg==
X-Gm-Message-State: APjAAAWB9+ZrwLKrgZK7+0ZTp9xyON0hGjCrsjs7BfIDQrCbmpWWWp7O
	P1E+YNob8lfv1d4ZFUb66cNM20Np73eqvb/BQ76MCQ5KXJGvSbkHQGo7e5plnMh0Q7J/VmmUqi8
	5BjM815fEJg1rSjgJ6MjG+iwF6koN+jUchfmKG5wAU5H0xceQX97lPyleFyY5x/A=
X-Received: by 2002:a17:902:b58a:: with SMTP id a10mr51563630pls.83.1558430017289;
        Tue, 21 May 2019 02:13:37 -0700 (PDT)
X-Received: by 2002:a17:902:b58a:: with SMTP id a10mr51563568pls.83.1558430016408;
        Tue, 21 May 2019 02:13:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558430016; cv=none;
        d=google.com; s=arc-20160816;
        b=XiMMxHzm1M4syHn4D2CT1/3zg64nT6q7XjVvXOgSIYzZkasiiBRhA6ntvT/xdQv67e
         42LWmzWK9AUq13KHkVr/DD9rcDZ1gmfIqodULIv/ROfVHKE6HslvSoYWQnNmZElxFlvs
         CKH+TeRG4YD0uIRwy4a2JTxdnU6O9fyEqZjHT1tIee0DgfMgN3rz/97eX9m0irFxQwiC
         3/LbAAjLOW3Xylh+TmHHzPBzrtU6hjQwnRGtNRuqjiTngftDmdagYvFb7QjfKwv1hiSt
         ye2jNA6k8gRdCRtKfSpFOUM65mpHd3okx5j13q0xLfaeijwhS64h7QgwegjNHpFfNGYd
         uXjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=FtiVzriB2PhlcNAnz836XBuHzMztzkTorf7MJccM2OU=;
        b=QeI0h6DZBna3MO4KWzdCrxxpnC3c4vFalL84rbgnwnL7xdkPsQgTbq+EOGQ9BXw/pz
         ckW3mnMMRk8fMXQkmmFajgzcOTiP5z98FKOoacq6wwwmry7h8YKMnfe8+cs4m/5oHndj
         svGpNO3AKIkck5CwjF2Ia2HMKGvREOr6h7vLpa16uSGdt6CikEuB0xBwIjitT2AkeT/s
         iJbDupoZoOB/BQfhZRBlWXXK75q/H7ybQlR1X5H3JSaDDAZ20M1983IEmxtL/+3t4bnj
         fxzxazRxcK/vpwwcZ7ZddPWCkuRRUCuK9MuYGuWLCvqdSpLPgXwlE0/jaMfHVgA1jSpx
         DUfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nLpAdWEL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y82sor21784895pfb.65.2019.05.21.02.13.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 02:13:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nLpAdWEL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FtiVzriB2PhlcNAnz836XBuHzMztzkTorf7MJccM2OU=;
        b=nLpAdWELdczUu+3lNyH6LfAl0QPj3HY+ylBRF+etXwbxLii/AXVKvL8Z2X2jUNDnDZ
         oOLUXjIgc+XGGxCeO17/IM2C1kUUN3SNtqpO/c6t/XJsrP0Ux7ktXDgHHS6EZdf8LFek
         gT5vJlMs8DrcCOeK7IrChtx97Zx1dbwWji6WwZBR8fpQRjgPj38fDcpr2Gtlrgd8zy8I
         uNh+aVGyi3WWAXJOrRiWrfeXZD4lN9bimqQB27OGtybJ0B3hz4egDMmNJDLGMpWTnPEQ
         4Vkk7lk+1VlnoIdxFYKpwVNCusuZtNP1TBbUsXL6/pt0+8CzePg6WX5gMb7XebjpDCG2
         xUQA==
X-Google-Smtp-Source: APXvYqzVkDpZ7bX2Y7PzruSEK13LfO/mpDsKUUI4C9vtExA5uiJNVqQNkd9lzLO29jDx3IZd8nI4Sg==
X-Received: by 2002:a62:1ec1:: with SMTP id e184mr18958178pfe.185.1558430015975;
        Tue, 21 May 2019 02:13:35 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id u1sm31870394pfh.85.2019.05.21.02.13.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 02:13:34 -0700 (PDT)
Date: Tue, 21 May 2019 18:13:29 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 3/7] mm: introduce MADV_COLD
Message-ID: <20190521091329.GB219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-4-minchan@kernel.org>
 <20190520082703.GX6836@dhcp22.suse.cz>
 <20190520230038.GD10039@google.com>
 <20190521060820.GB32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521060820.GB32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:08:20AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 08:00:38, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 10:27:03AM +0200, Michal Hocko wrote:
> > > [Cc linux-api]
> > > 
> > > On Mon 20-05-19 12:52:50, Minchan Kim wrote:
> > > > When a process expects no accesses to a certain memory range
> > > > for a long time, it could hint kernel that the pages can be
> > > > reclaimed instantly but data should be preserved for future use.
> > > > This could reduce workingset eviction so it ends up increasing
> > > > performance.
> > > > 
> > > > This patch introduces the new MADV_COLD hint to madvise(2)
> > > > syscall. MADV_COLD can be used by a process to mark a memory range
> > > > as not expected to be used for a long time. The hint can help
> > > > kernel in deciding which pages to evict proactively.
> > > 
> > > As mentioned in other email this looks like a non-destructive
> > > MADV_DONTNEED alternative.
> > > 
> > > > Internally, it works via reclaiming memory in process context
> > > > the syscall is called. If the page is dirty but backing storage
> > > > is not synchronous device, the written page will be rotate back
> > > > into LRU's tail once the write is done so they will reclaim easily
> > > > when memory pressure happens. If backing storage is
> > > > synchrnous device(e.g., zram), hte page will be reclaimed instantly.
> > > 
> > > Why do we special case async backing storage? Please always try to
> > > explain _why_ the decision is made.
> > 
> > I didn't make any decesion. ;-) That's how current reclaim works to
> > avoid latency of freeing page in interrupt context. I had a patchset
> > to resolve the concern a few years ago but got distracted.
> 
> Please articulate that in the changelog then. Or even do not go into
> implementation details and stick with - reuse the current reclaim
> implementation. If you call out some of the specific details you are
> risking people will start depending on them. The fact that this reuses
> the currect reclaim logic is enough from the review point of view
> because we know that there is no additional special casing to worry
> about.

I should have clarified. I will remove those lines in respin.

> -- 
> Michal Hocko
> SUSE Labs

