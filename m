Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A690AC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:58:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F2492070D
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:58:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YddJ3EXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F2492070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE29A6B0270; Mon, 27 May 2019 03:58:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D95096B0271; Mon, 27 May 2019 03:58:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C82586B0272; Mon, 27 May 2019 03:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6326B0270
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:58:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q25so3151615pfg.10
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:58:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AtLyxtk9Dzb+m0497auHuXX2nLc0N/zfXlXDKG81NXE=;
        b=mj5B7SVhwStN+rJCj5BJ4J8hBu8hqWObK3V1YTpZ0w0GM7ZO8u90PM0nztBYRlYaxO
         AWLvL8Fvetmx5RcvRCbCDnGVmooo60foPI4++CKhShHzgsuPoTvtPqX1gEPVqRfebCR4
         xpYC51mvyVVaFBG/kDGQnWL7IYHgaefJuUMRzAvPBRgKQPt/58qLzwNpH/APw3Ht+Mcp
         Ot43kqUI61T1dqzg0qZkt6YNAtAFcrYsYypWWYKEUnXAFtAm2YLbOljn7/crOXw/RQqm
         Mlloess47YOukdZHuch78pWmcWzQ5u5DzTp5EUzCZZNOlVcF5QL4JnHWmFvYxHssXzgU
         ZWWw==
X-Gm-Message-State: APjAAAUEKGAWiKQqL1asUM7U3+8wScEy7y8jIKJISEDbI/bHz6qBVZRN
	ABhZdmSM6yAmVj7ahh4OxLu8GF+DOrQ+YDuvx4SFkkJtan6lAgmgGvGsWQJi3t4jEUK+tbB/m03
	coiYxUx4u0PBBS4b9gTxwY8PXvxCVcFQtf8UDIlntZ9iBQkwKvt9PClKIXfAA76M=
X-Received: by 2002:a63:3dcf:: with SMTP id k198mr125582646pga.60.1558943899031;
        Mon, 27 May 2019 00:58:19 -0700 (PDT)
X-Received: by 2002:a63:3dcf:: with SMTP id k198mr125582567pga.60.1558943898165;
        Mon, 27 May 2019 00:58:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558943898; cv=none;
        d=google.com; s=arc-20160816;
        b=P1onZdW2+/6GVPlYxes3ekYsEhwIFwhYL99Twb1QI2dR1IW9Z/MZqG+X7V3bq9kgM5
         FUAaCA7L1s5Ik4okIo2EatVTHSAPhLHDXp0qFg+r70bGENHa6NMqaSV9NwMqzi1Bsm0a
         2EagNVyJNdCQ8fk93+OqjpP/Luw2PygobX2Zo/+z/HrjdupWR0SUiUcixv7wTvD9vRY5
         3dnMxUADafK8+H66igFj5PltokqPJVHRclYsUqm50yYOaHKugSZXxZnUc6hsPP6lKBmX
         rE4HAbRlmfX5GN5JHnk9OXhi3/YeJ+5z+jkmaBX5roafXGdzkxd6WtI3d+yVx2Lcd1Ou
         /TBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=AtLyxtk9Dzb+m0497auHuXX2nLc0N/zfXlXDKG81NXE=;
        b=VSFFHj8D/YFbgyjv4T44bbVw1I35cYJb4q3zKPSIefCcUDFhgPbu7bSrQNumBBHUet
         8TnEBE47urK1BcVXFLbAQxrtD7+S+lo1W4hJ+Bt1qxFeYDI6puXNFV/V/77tiiThS9R+
         kyFWjU8Y4MV9MBHUvqj+Sspvp++s4VtHy6wxESXLe2jzGFcLbQYjn/i/gQBS1DCkvc97
         z8MXWWuQBJk6zO+oQtrWWB+xUYIpm2Dyij6h8O0wR590x4ZOULSSmp5TGkyWbweOePlm
         hyeN9FYpw884+zgVBVjSe7bbvtQEBdeFJAoGHN1ygvl1kA9RVV2zjU9ZAphkHF+vWQnH
         SUEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YddJ3EXG;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k75sor12067903pje.6.2019.05.27.00.58.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 00:58:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YddJ3EXG;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AtLyxtk9Dzb+m0497auHuXX2nLc0N/zfXlXDKG81NXE=;
        b=YddJ3EXGsxY4Mae6Yosu3sXkx8hcN2mk9wf03Iho6huUQyCPm36tLZN9XRHcwwl3Li
         VZaWwsKHHQZcGjze8MpJwBYvZOr4/JFoZqb2BPJXB4vYBfUDiYxmmmeOW3i5Nkxxl1sA
         P1fefUbWAjWl4KGzjTUuRKEIyJuI1s/2DqcJ3DorxbS8UENXyLrPmziVxPdpJ+rBCOF9
         YomHgrYFvLVxqilDv0CmZeyCuZyUeOhpTLmA4D3xEhFkTGRV8ptiiK2Ma+ENptkVk/mR
         m95QZTxEYEUNCpACv/zCSylIB2q9gUhh6hNzdZIxykp8t69jthBbipxfdll4UlP3zuWj
         kGOA==
X-Google-Smtp-Source: APXvYqy7Ciw4BWJbHLqJmf1T3VmgXQeVxglXh68Qvk5eTkT4dj+InYqIzbs2GO1rQP7sg3r1fXpkAw==
X-Received: by 2002:a17:90a:b885:: with SMTP id o5mr28965553pjr.52.1558943897757;
        Mon, 27 May 2019 00:58:17 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id d9sm8833891pgl.20.2019.05.27.00.58.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 00:58:16 -0700 (PDT)
Date: Mon, 27 May 2019 16:58:11 +0900
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
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190527075811.GC6879@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521062628.GE32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:26:28AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 11:55:33, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > > [cc linux-api]
> > > 
> > > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > > System could have much faster swap device like zRAM. In that case, swapping
> > > > is extremely cheaper than file-IO on the low-end storage.
> > > > In this configuration, userspace could handle different strategy for each
> > > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > > file IO is more expensive in this case so want to keep them in memory
> > > > until memory pressure happens.
> > > > 
> > > > To support such strategy easier, this patch introduces
> > > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > > that /proc/<pid>/clear_refs already has supported same filters.
> > > > They are filters could be Ored with other existing hints using top two bits
> > > > of (int behavior).
> > > 
> > > madvise operates on top of ranges and it is quite trivial to do the
> > > filtering from the userspace so why do we need any additional filtering?
> > > 
> > > > Once either of them is set, the hint could affect only the interested vma
> > > > either anonymous or file-backed.
> > > > 
> > > > With that, user could call a process_madvise syscall simply with a entire
> > > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > > 
> > > OK, so here is the reason you want that. The immediate question is why
> > > cannot the monitor do the filtering from the userspace. Slightly more
> > > work, all right, but less of an API to expose and that itself is a
> > > strong argument against.
> > 
> > What I should do if we don't have such filter option is to enumerate all of
> > vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> > which would be painful for 2000+ vmas.
> 
> Painful is not an argument to add a new user API. If the existing API
> suits the purpose then it should be used. If it is not usable, we can
> think of a different way.

I measured 1568 vma parsing overhead of /proc/<pid>/maps in ARM64 modern
mobile CPU. It takes 60ms and 185ms on big cores depending on cpu governor.
It's never trivial.

