Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F08FCC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF2632173E
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aDa3BR5h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2632173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 477636B0006; Mon, 20 May 2019 18:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 400416B0007; Mon, 20 May 2019 18:54:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27C466B0008; Mon, 20 May 2019 18:54:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E16586B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 18:54:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f7so10001617plm.15
        for <linux-mm@kvack.org>; Mon, 20 May 2019 15:54:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j5ZEwZoUPrePvOB8P3uaFYHEBF9h6x1bF10qxviP/xE=;
        b=K+g/9yme6AHYWSfKIuv4zdiRBmxg5/rKmPtJGvhRECCAtfmXRG2rBGq1+Al7B4M2qe
         V5LP7HgCw9bUX7I3Za0TBSQr+MQixKXecJgeukEyO0aMCxeKfB2HTcnOrI5fbvBzKBTm
         ovw7eSTgsX2jLGthWVfa/wqBf6F4jlyhAgCIs8VuPI06fTmZNwnhbxVfrKclPrK1e3v6
         JU1nDcH8m8KTfEsw/pYcCx7GclFIoeqdbQ22jFYMcPjUDwnMzqN+O2Wqwzv189kiDsOI
         OdyRU+70SyIhzmhEsxP4dE1hDXA6ARNtGRJYZ3d1mdWMvcFDj0QxnkNHZQtXvhMxHa3S
         XLjQ==
X-Gm-Message-State: APjAAAU16yZp5BSQVK0vsJsoVxwv0wZOEXlU2in0UyaLPc0vjGW562IU
	h2c0opz2Q7fFFucrlPte2aFBecZb0QJhCr8/eAjWfweznKncEnX1/OYJTZXO/4CzqBe0clESfYR
	Oaqc+RBd+Ks+rTz4v2oMjAmFdNa8qScmj+3DXjf21NseikJyPco4SR4UdTXZpHj0=
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr83569448pfe.242.1558392867524;
        Mon, 20 May 2019 15:54:27 -0700 (PDT)
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr83569392pfe.242.1558392866820;
        Mon, 20 May 2019 15:54:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558392866; cv=none;
        d=google.com; s=arc-20160816;
        b=yT0+58S4kxzlAAgtNg/Pwrv39KiNKeeAj6xIicVshU9H0I9G6eisUZVX6HG7RxDr8Q
         mhwtJbl5yz6xQMs5iouO9mTnTQixi9GlBViOxXDxarRukg35pApiIB4CHY6JCNO+S3SB
         SkIHqR3RM4M2izSv5wOsdpBQ+/Vl5+VZClGY064UOWFbA6RO4JlfbRpso+M3dAw38A6B
         F0jEQ534L2uu1YnZWRu+TYa3tYYGvf052YeMHgOErahCJgWPXJX7TCEeDs7soTyB/eGM
         w6KcEzQv53WXgSB7ehXpTzednbqe2YgcsmLFtHerbEG5QUM5poBF0IYk1gubuA7rr7Zu
         LLOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=j5ZEwZoUPrePvOB8P3uaFYHEBF9h6x1bF10qxviP/xE=;
        b=Yq8xcw2wk9ERS8vNrRVC6+IMx9H+0Z5po45Gr+v7SGyQFgBGIQL0KvOsNyF1Vatq+4
         36OPWWFGokLrIsj+rP8l8yBKqKtCZt/Dqid3rQ31f9CaeRylYbbBbGB5TbrMttfC/YVz
         NS/+PuW02qyNX+9KHWlYWr4RV6/hW7+nFV4bzK3tr8v3foYQPRwUY4NFFFJdY0cOz5kS
         +jIJvU8ERaJfUbrwIltQ+8NF/H92m3Q5Zn4CxS1lQDr1rj4lI4Em5b5K9NJ3Bw/pnkQv
         k5YIjlhOmc15S5r6L9kyD0/NsqQsYaoT8fErQU66DXOVudxHCb99pw9gbezRLnZ7blko
         MAOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aDa3BR5h;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor18961024pfr.69.2019.05.20.15.54.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 15:54:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aDa3BR5h;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j5ZEwZoUPrePvOB8P3uaFYHEBF9h6x1bF10qxviP/xE=;
        b=aDa3BR5hrVujffR2CccTn2i03Z06u8RLaJv5oWvHxj5xbVNGiYsJk/vt7209S8uAol
         cSUwKywUIzkbz99ygGpCwDVlyAhlP6Qqv16/LS7gCBDlBqt07w13Lm6/MhAubCUgw7do
         9mS7NAcuScAF4itUbYLknC0Rx5EIrxuTy8Un0xtEN35JX6X4Ul9oGrEZvRiI6PizjfsO
         8TUxwDnLaJ0suX9Y3ukM8LQoqob/YnSrmTYafRjigxMs8VqXRDeuhNsTaiq/zSWYqRe+
         O3paGwlyrZnmuqoURl77Gg2gHg6KjGkOKu3t7IebRgpgTp9yfW65T+GgqdpR0uC3WLXF
         UYfQ==
X-Google-Smtp-Source: APXvYqzzK62nVCC5F6/m31S+JkD0c1anhEeHQjGso6nctGro5sKQZujkk4vsGaYEeFlhkah4BFhh2Q==
X-Received: by 2002:a65:52c8:: with SMTP id z8mr9234274pgp.10.1558392866292;
        Mon, 20 May 2019 15:54:26 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f29sm47171591pfq.11.2019.05.20.15.54.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 15:54:24 -0700 (PDT)
Date: Tue, 21 May 2019 07:54:19 +0900
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
Message-ID: <20190520225419.GA10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520081621.GV6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 10:16:21AM +0200, Michal Hocko wrote:
> [CC linux-api]

Thanks, Michal. I forgot to add it.

> 
> On Mon 20-05-19 12:52:48, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range
> > it could hint kernel that the pages can be reclaimed
> > when memory pressure happens but data should be preserved
> > for future use.  This could reduce workingset eviction so it
> > ends up increasing performance.
> > 
> > This patch introduces the new MADV_COOL hint to madvise(2)
> > syscall. MADV_COOL can be used by a process to mark a memory range
> > as not expected to be used in the near future. The hint can help
> > kernel in deciding which pages to evict early during memory
> > pressure.
> 
> I do not want to start naming fight but MADV_COOL sounds a bit
> misleading. Everybody thinks his pages are cool ;). Probably MADV_COLD
> or MADV_DONTNEED_PRESERVE.

Thanks for the suggestion. Since I got several suggestions, Let's discuss
them all at once in cover-letter.

> 
> > Internally, it works via deactivating memory from active list to
> > inactive's head so when the memory pressure happens, they will be
> > reclaimed earlier than other active pages unless there is no
> > access until the time.
> 
> Could you elaborate about the decision to move to the head rather than
> tail? What should happen to inactive pages? Should we move them to the
> tail? Your implementation seems to ignore those completely. Why?

Normally, inactive LRU could have used-once pages without any mapping
to user's address space. Such pages would be better candicate to
reclaim when the memory pressure happens. With deactivating only
active LRU pages of the process to the head of inactive LRU, we will
keep them in RAM longer than used-once pages and could have more chance
to be activated once the process is resumed.

> 
> What should happen for shared pages? In other words do we want to allow
> less privileged process to control evicting of shared pages with a more
> privileged one? E.g. think of all sorts of side channel attacks. Maybe
> we want to do the same thing as for mincore where write access is
> required.

It doesn't work with shared pages(ie, page_mapcount > 1). I will add it
in the description.

> -- 
> Michal Hocko
> SUSE Labs

