Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCC39C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FE9B213F2
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="je0V+f8q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FE9B213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 229B36B0005; Mon, 20 May 2019 11:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DA156B0006; Mon, 20 May 2019 11:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3176B0007; Mon, 20 May 2019 11:08:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B54046B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 11:08:57 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id n9so6699785wrq.12
        for <linux-mm@kvack.org>; Mon, 20 May 2019 08:08:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P9y3c6/pdf3tbErI0Do1diigP58TG78CE1J0hIezm6I=;
        b=rSNFpiEfv/CrEbn4dHE/CPFdcQ0LiK02wnfyju+wiCTf3rXWe9TGxWPbrmVgLJcLNp
         gOyV5PaK2hQLRuRQXdj/TkuLRaY6H5G/FStWkRbdSUMGkMfH4PUs5+aJuCHqVGOAgOE0
         DZYg0+qeE/MzEle2xvsJ8ZJ4GQxoslj9qa/Ant6/Tc8PCt2OcRzgMlaEcroA0CF78Zbw
         jtyed6BA7Odfmjbv/qkOTc4DWbAPxErYscfC3wvffuE53P/UUDuLUiHoTRg8ff53r8LM
         XMQicnVhhx9DfMHFQc8VeKQKXpTp9SW2DPKhkTMNGsJktNzrrdwaohFmMvNR2iaFPtbw
         0I9Q==
X-Gm-Message-State: APjAAAX33HIZldGFrxQDxEJ4iqNSyiBialgQAsIgbsXhhE0wNwOQjPkb
	OMAlaDHuO6be1FB3QyBe02Ix5FNwqNN+LvU/0/p3M5fWCqTKyPw9gq8WuBexNV4kqwP9gOx2Mw6
	RYy0lbyxqffaD3ZcijPW/NWqXY9rMjqMZjMlg5J7homdXM1aw1jbOQWLK46OF71QXyA==
X-Received: by 2002:adf:f80f:: with SMTP id s15mr19169047wrp.322.1558364937339;
        Mon, 20 May 2019 08:08:57 -0700 (PDT)
X-Received: by 2002:adf:f80f:: with SMTP id s15mr19169001wrp.322.1558364936591;
        Mon, 20 May 2019 08:08:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558364936; cv=none;
        d=google.com; s=arc-20160816;
        b=IVwwioVWfAGSVEx8oevq9B7qrfTQvq06hz+fLJ0xOOrGOcTbZQIwsSFgNH1S1gKGPg
         3giWbfKCe6tsBOkIcUyaq/n0MDwYQqKaRB7wHbMITI7iWMjkjcfsqjRgHyFvCisdzoPk
         sT8NcfYzlOabCksTJQUVqxA2CFjCUCCkGUig65lUW64LfyORRwc6fuJzJc5iWKG7NjyM
         8r8K+9rLzvhyTjKrCn+F8enOLGyA00mY36/xrvqTDgJqkcX856jkSZBWCSql0sjrh2m4
         Eoz+RpdIyKx3K1WRbD8AGyjwF+JAHqSdcgkDvMWvL4SmhhnYWtX8f2a4Bt5CvWGOhz6e
         0WCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P9y3c6/pdf3tbErI0Do1diigP58TG78CE1J0hIezm6I=;
        b=Y3xyznnLbDZfn3TQWhX6wUyntSde0BsFwoIlWQ6zB9n04YQ0lr10WudFsj0GPdEQM9
         hhj5FdvkggeTcscK7zljPSvo9xQg8fNKmlw2iaJzbAPb8zxc+3RZJbFztpg1IWKU6Aj1
         lWkRmvMmGAN6w5hhuOKvZhE97B4n+9f06LCI+W40JeSYVqNMj7F0Ym/+oIYgw/AICQgX
         oQBhbgOUc+Sle5q0/u/vN6FXtZribsjgShDxE3pG7pC2vBYMGvnjHit2xAvBsCtZOgEQ
         Q4hmgNndwtZGfvS4Yj3D3ibCqsUkPM6KsTKQAmnqYs22DaHSAfT/3M6WySaXsyDJ8ljX
         bBAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=je0V+f8q;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o63sor4558884wma.3.2019.05.20.08.08.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 08:08:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=je0V+f8q;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P9y3c6/pdf3tbErI0Do1diigP58TG78CE1J0hIezm6I=;
        b=je0V+f8q316pSmPHnXBh0zlNCIMMIf0OTbOsKzKgqpiT5HJoGx7mgp0OmmrbCA6ypD
         T+8lsnJPKUBVQTt2YUj4Hjldoscaw/3gfqWtUsK/glWrq5k2hsbzgoAW58zf0vxCqogH
         GOdrfDuW/v5LxD5eTjNRHz5sknGLMr+DWSpm8/Fy7P5AsMxnI53jQ8fTyN5GuUIlLR9Z
         S0up4Y3meHZxSb07WX1pbkLBgwWdNf3po14WBinDKeARTl6purwLBpNsNE3KYHuS+6c8
         zfd6w/dQFy7+34oXkA4FVEGxYMhLqFuhoC9SyGvSo65ZV86AJ746EGnz1oC6vjAbDD+i
         QqmQ==
X-Google-Smtp-Source: APXvYqwTvkGu1GK/0tSXG4iFUHM6unRNHVZf1lF2nENMPjqEy8F0XxkWnj/B1GwuSNTjbSbtEZH2Wip0AFBPNQmrDik=
X-Received: by 2002:a1c:dcc2:: with SMTP id t185mr11431100wmg.143.1558364935763;
 Mon, 20 May 2019 08:08:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz> <20190520081943.GW6836@dhcp22.suse.cz>
In-Reply-To: <20190520081943.GW6836@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 20 May 2019 08:08:45 -0700
Message-ID: <CAJuCfpE60ZOcpFfE6MpF0PBujK9sfeRjbkhUa243Bo9QmOoARg@mail.gmail.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Daniel Colascione <dancol@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 1:19 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 20-05-19 10:16:21, Michal Hocko wrote:
> > [CC linux-api]
> >
> > On Mon 20-05-19 12:52:48, Minchan Kim wrote:
> > > When a process expects no accesses to a certain memory range
> > > it could hint kernel that the pages can be reclaimed
> > > when memory pressure happens but data should be preserved
> > > for future use.  This could reduce workingset eviction so it
> > > ends up increasing performance.
> > >
> > > This patch introduces the new MADV_COOL hint to madvise(2)
> > > syscall. MADV_COOL can be used by a process to mark a memory range
> > > as not expected to be used in the near future. The hint can help
> > > kernel in deciding which pages to evict early during memory
> > > pressure.
> >
> > I do not want to start naming fight but MADV_COOL sounds a bit
> > misleading. Everybody thinks his pages are cool ;). Probably MADV_COLD
> > or MADV_DONTNEED_PRESERVE.
>
> OK, I can see that you have used MADV_COLD for a different mode.
> So this one is effectively a non destructive MADV_FREE alternative
> so MADV_FREE_PRESERVE would sound like a good fit. Your MADV_COLD
> in other patch would then be MADV_DONTNEED_PRESERVE. Right?
>

I agree that naming them this way would be more in-line with the
existing API. Another good option IMO could be MADV_RECLAIM_NOW /
MADV_RECLAIM_LAZY which might explain a bit better what they do but
Michal's proposal is more consistent with the current API.

> --
> Michal Hocko
> SUSE Labs

