Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AA09C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:11:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E1CB216B7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:11:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P5we8Zz6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E1CB216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD1F26B0003; Tue, 21 May 2019 05:11:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B815F6B0005; Tue, 21 May 2019 05:11:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A70506B0006; Tue, 21 May 2019 05:11:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 701846B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:11:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i8so11934883pfo.21
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:11:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aOt4vo5keUTXDvxZZjRtcBm1aK7jMfHXMFBxDuIODzA=;
        b=jZq/PJMo8t/2SzS1i7CgXl7R/Y1ITnn4xv9V9wRP63jWE8JQD7Hx+3iBOY6Oj37FlD
         PsfztUprsiH2k8q07GGqXBU1pyshMujhqIeWEdDEQG/+T8zT1aCUhtprwx49Ktg/TJSC
         t8sZOCyrQcnyhjY0iwFg5fJmIR8LGgyZxJIwJG76x+cNlBGwzF62ZLejPTfLObvaNr2n
         Ldp7G1X1rRU/ePoNqpKboA5E+EO7PLBPIlT/+vxYTvHQeUhorPd0XdErb34JzvCD+mKY
         7r7DnGG+aKGDmX/xmEMn5UziXLpsSCfmV251gJhTiPxcLX1tqWcpSOcI4AETJnBW9eU/
         4/jA==
X-Gm-Message-State: APjAAAWatwUtCCCB0wyLl2BKX/hIf4yrX15kihv6sERuQ04ZE99CRyjA
	LZTLptlxIznR6yrF7U9TjG7WjY493Q8zrOKDrk87a3jXkNeAR/3QYCoR9xrkeU7QJxkoM+x2Afg
	wKyeKRnFojsIokrjBGQtuw4Ms/GQUkB3uYiHx5Lmj2TjoF85eDvajDy+i8LwriOA=
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr25469271pff.238.1558429903086;
        Tue, 21 May 2019 02:11:43 -0700 (PDT)
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr25469200pff.238.1558429902318;
        Tue, 21 May 2019 02:11:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558429902; cv=none;
        d=google.com; s=arc-20160816;
        b=ATwEAtkAEUOhFUjg+ep28vBlEVrfErGUgEMm4/r0jPC5jcMs6Alp5siICtgx6ptZ9R
         P7hklfcik1qI6qZNZWDNBQd71hVHdtdbCFcd3XI929BKHe1219VKV83GlYxOYSFM1CM/
         k6S2CWqm4gqwdClCITYTc7HpVtn8hwTDWowrOmJL4DGebdXlg391CCo1rqPdQ+/yg002
         KGodJpW1IZSSYmXrc86/XabL/Fbu2QWrWpdV9id6rhBZY9kmTZPowdkonPJw6o1eXv3m
         l8t2b+iKEX1Ng1r99lloFpG1cPTqn9zA3CefYLtyOb1MQpjocuh0K4SMrr1E79dfNnlG
         eRFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=aOt4vo5keUTXDvxZZjRtcBm1aK7jMfHXMFBxDuIODzA=;
        b=A6ktgiVkocApPHWM31Mqfonh93L9+rilOBazwwGFZZUSaYbrU2zrxF1WIN4FjKyduM
         dvhtJzPYAQHijP0Y5xQlUdiME64lHp1o+ymBpWhDcF8WRwISkTzHjBJl/p9L5BM5GRdI
         dOkNLX40kxZfLUUqXmd8pEB6oKNPmJGZGFFhuXFreprKS4WZ0xDs4cF+uGHaR1HxxMmf
         vmPL7oqlzC1/gOSJuuPeKJFChNOF6C2Y7ovES4m2LNqUt/qSnRs2M6AmaeDdLGhmyAs+
         xFgFF48NS/MhfsdVsi6/Fb9fzQs/50M0Vp6eBf0Hvog7qjy9fUOVE7eIJ5CQN9L1mH0J
         VdKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P5we8Zz6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor21175062pfe.8.2019.05.21.02.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 02:11:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P5we8Zz6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aOt4vo5keUTXDvxZZjRtcBm1aK7jMfHXMFBxDuIODzA=;
        b=P5we8Zz6H+6S4VTlk2sRyHDyYEYpXZzybP9tIIBSzd43r9y5MSZBdRXPlBJ3lryTA+
         FWOEAmz8w+mqOLE+LcNWuJ/ve9kPQPP8/phO01R+hpObYwiJzOU+mo9bnHu8oNM243hL
         clYHRejJlOIAMzdHvAOiJEhHVDOa2d3OqbZ7SHHr7QP9bdRstiaxodxpUI3z/JqLn0l4
         CuVATlGmo/EyAaq4qPMaqhxYBgbZoh/4BquhmIPGWKdQjcfQP+ng4zk+hWfL7XFYdTlr
         x1rygty1O865cqXgXvCFhBnp7eKJuEOmFIKJmbeFTSlJ6axhVPY/QRu6T1S+43OepZ+a
         qeZw==
X-Google-Smtp-Source: APXvYqzQ29qPyHCPNtNMZdW9Eoc/R5M5CuB8zMitb7IkSgZN/cNPBHHU2P0y4NCtkKDQjLnHnvvwbA==
X-Received: by 2002:aa7:980e:: with SMTP id e14mr86228912pfl.142.1558429901695;
        Tue, 21 May 2019 02:11:41 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s19sm20707713pfh.176.2019.05.21.02.11.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 02:11:40 -0700 (PDT)
Date: Tue, 21 May 2019 18:11:34 +0900
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
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190521091134.GA219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
 <20190520225419.GA10039@google.com>
 <20190521060443.GA32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521060443.GA32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:04:43AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 07:54:19, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 10:16:21AM +0200, Michal Hocko wrote:
> [...]
> > > > Internally, it works via deactivating memory from active list to
> > > > inactive's head so when the memory pressure happens, they will be
> > > > reclaimed earlier than other active pages unless there is no
> > > > access until the time.
> > > 
> > > Could you elaborate about the decision to move to the head rather than
> > > tail? What should happen to inactive pages? Should we move them to the
> > > tail? Your implementation seems to ignore those completely. Why?
> > 
> > Normally, inactive LRU could have used-once pages without any mapping
> > to user's address space. Such pages would be better candicate to
> > reclaim when the memory pressure happens. With deactivating only
> > active LRU pages of the process to the head of inactive LRU, we will
> > keep them in RAM longer than used-once pages and could have more chance
> > to be activated once the process is resumed.
> 
> You are making some assumptions here. You have an explicit call what is
> cold now you are assuming something is even colder. Is this assumption a
> general enough to make people depend on it? Not that we wouldn't be able
> to change to logic later but that will always be risky - especially in
> the area when somebody want to make a user space driven memory
> management.

Think about MADV_FREE. It moves those pages into inactive file LRU's head.
See the get_scan_count which makes forceful scanning of inactive file LRU
if it has enough size based on the memory pressure.
The reason is it's likely to have used-once pages in inactive file LRU,
generally. Those pages has been top-priority candidate to be reclaimed
for a long time.

Only parts I am aware of moving pages into tail of inactive LRU are places
writeback is done for pages VM already decide to reclaim by LRU aging or
destructive operation like invalidating but couldn't completed. It's
really strong hints with no doubt.

>  
> > > What should happen for shared pages? In other words do we want to allow
> > > less privileged process to control evicting of shared pages with a more
> > > privileged one? E.g. think of all sorts of side channel attacks. Maybe
> > > we want to do the same thing as for mincore where write access is
> > > required.
> > 
> > It doesn't work with shared pages(ie, page_mapcount > 1). I will add it
> > in the description.
> 
> OK, this is good for the starter. It makes the implementation simpler
> and we can add shared mappings coverage later.
> 
> Although I would argue that touching only writeable mappings should be
> reasonably safe.
> 
> -- 
> Michal Hocko
> SUSE Labs

