Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7C77C18E7C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:50:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E722173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 01:50:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UjHLINqa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E722173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D50226B0003; Tue, 21 May 2019 21:50:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D00A16B0006; Tue, 21 May 2019 21:50:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF29D6B0007; Tue, 21 May 2019 21:50:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 845306B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 21:50:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e20so604129pgm.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 18:50:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KEsTTRLdcPvr4DyB6nsvDnVWKWacN5V2AbAsyIXP34I=;
        b=K7QSklbnoOvQ1YrIXy9nJCOzLr9yZ+/8fv+cydsFjP14PzyjvPHLqr8s9jffQ4KZIy
         xSpT/N7vKp7ygGeckJFUiNwBf07D9Thquqz+lEauNNe4Rugp0CUryXmH9nJWi92o8eft
         bZOro4Tv7D7bsGBMGBZWcvb1b7ovqDS6Tqp0NgX/SlTSg3LoOagRg189z8MWqRKFfull
         1mQjQ2DCzH/MQNirAjyLbG259sAT07N+J1DhR7U8oYFZ8lUIh4gqAXm4RYUw6Wq2Cxlu
         WRWoKoeGSdxB6JGsBDTqcYSUB4nqwQEq5GHVLZp+WJvN4LLYgis5R+OUeUP79EOeR1/a
         pxBA==
X-Gm-Message-State: APjAAAUKRlI5uWuhyjBYeGZbbIphI9YCvQzHhNzg+wWruKHOJ6pxm5yk
	760IUkBmJydF5mKDLjFl9k1rUohH+quXQVx1r5V6mEsA8JPXLiCPddhibAhAi7h2GREy6XNgDbm
	MgH1T2UO4zR8KZvSsy6L2etkvhYWi0s1TI77ibia58La3imO4/zxMJooEWE33P6E=
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr91629280pfo.211.1558489834069;
        Tue, 21 May 2019 18:50:34 -0700 (PDT)
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr91629184pfo.211.1558489833262;
        Tue, 21 May 2019 18:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558489833; cv=none;
        d=google.com; s=arc-20160816;
        b=Aw12F/kAW8Im0+J/t49s/cV1sTK5jUmudCSyGv4bOyUDey7oMGDtyxYH1xP4DellLd
         2vvQbo96VDl142hd+rA9zIq513UEYuqAvEmThfxtIZ/oqDTs1XBFZltvgtRzTrszVwFq
         3O1R0NTAEIqgQKdKIddZxNzuCSeTHMo5uPs9UQ1vtaC7TeXhBdsD59Gq+zdsu9xaf8/H
         jiYliqeNFcKnqpuH6nZOgb4utpQ3J0fMIeGVKB7jmi5lD82Fl2GajBl+QSjgbLtLr5tH
         fvH3xtCdmYQmCyyjaC0EPTPwq8YGx00Y1MK/ylrioXSk5boXwOG+iBOpUSOlLEMDQ2YQ
         mz0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=KEsTTRLdcPvr4DyB6nsvDnVWKWacN5V2AbAsyIXP34I=;
        b=qCgofANqoqVX172U5orUaqosxgjv2FE1fu+jHcdQq4GvQkNJGWcOxXvhEtvS/xJ2R2
         qwmUhTLBQrrLk9Xt85gfQVbIW0MI42LE67LKSRaKOCCyLmSmmmBXLn3D6k4zBsD0GcuS
         ThHJMNkdVfpru8kSODj4eabG9l6mLZLq+l1YEa895Xq2UhE/4sZSTy1Ti/0af9etH0lV
         +h0vDS7PJE5Vr4T59mMTi1Nwnt9yuQik/U5wkEdGtR2M4Je1VZrKEbsP8lMoAHS17gu0
         cc8miVB6jBobt2eEOi27awJj2eCJkxnh63zJ5zgn/WIZYsYrRx2y9U6S6CipxqHYQhqd
         09vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UjHLINqa;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor5458593plp.31.2019.05.21.18.50.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 18:50:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UjHLINqa;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KEsTTRLdcPvr4DyB6nsvDnVWKWacN5V2AbAsyIXP34I=;
        b=UjHLINqajyRyc03bkbJEwVX7nyyMpQmWAyv5W7+imFIOFa51iCIXk7CK/61xyyRIai
         FGYl+HB0sIXMbUhOTJDJlmDRS2bCzV0qCGUqghC+DnZPDQp1xWuscp4ICweSbOG1v4p5
         FMbXHwFzUmECuKMiVhzbb1ysJXHPR4w7qbNPVaEJxDG1Xc/OU5cYB1WHPyDB71x9sBqD
         K+H+qxwPPSAbqOlZmB9z2Os4xKbVMMtHfZ06glc1KrU6zwbHYph/usPPsgWR5EvW2NFB
         eSZRhhUszhkhdhGDKNcykyGEq6fUojSTYBiRH5bYQgPXAdTX6rN8GRTnhS29HUp8ht7t
         9vyg==
X-Google-Smtp-Source: APXvYqzxNfYUeQPKEfHm11BNLPHtdaRoG0oDRvWdcFYfHEy5dbahZDUKE2b+2g5lZcbEDfmXMxPRIQ==
X-Received: by 2002:a17:902:b108:: with SMTP id q8mr81677417plr.110.1558489832732;
        Tue, 21 May 2019 18:50:32 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id u134sm32855756pfc.61.2019.05.21.18.50.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 18:50:31 -0700 (PDT)
Date: Wed, 22 May 2019 10:50:25 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190522015025.GA29449@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
 <20190521153310.GA3218@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521153310.GA3218@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:33:10AM -0400, Johannes Weiner wrote:
> On Tue, May 21, 2019 at 11:55:33AM +0900, Minchan Kim wrote:
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
> Just out of curiosity, how do you get to 2000+ distinct memory regions
> in the address space of a mobile app? I'm assuming these aren't files,
> but rather anon objects with poor grouping. Is that from guard pages
> between individual heap allocations or something?

Android uses preload library model to speed up app launch so it loads
all of library in advance on zygote and forks new app based on it.

