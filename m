Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC3FC28CC7
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 10:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1CAD20859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 10:12:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oT3Tgck9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1CAD20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5896D6B0269; Mon, 10 Jun 2019 06:12:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53AE06B026B; Mon, 10 Jun 2019 06:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4023D6B026C; Mon, 10 Jun 2019 06:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0547D6B0269
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:12:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so6900380pfb.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 03:12:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UpQZyxDAIZssxN7CCNuXeFikhiebMI4lHnTfzcrIiyQ=;
        b=FmABJDukylyDyMMX4GcmmHTbNnNV1Sb9YmN5vR9ulOoTnH3tQ52Hl3uIfq9efkDZGw
         /SAUQ06mrkn6Cg6daOBmwhTSGaUBrngjIkRJycYk7/SYPlyfLZbIEx9VKoMJvKBD/VNC
         qEUBVP506ljoVKTmdHTubM/Dt4PeUbLrig6wrblivNTtwFQTT5OHJxfqIUx/4CLnK5LD
         P+kGEbeywSBu1g8nAmhLJ575MPzM6nBGbVSECs+uXsN2G9cMJB34YcaqV+MeMUIoDdcE
         pJ/wq3ej5Ut5OhiC1OBU1e/Os93yTDDab1T611CW+wJPy+7qBBlElichU81OB9H8MAO6
         1BXQ==
X-Gm-Message-State: APjAAAUqARmKzVrrUoibDwKGn8z5zf1Sy2ngS3fWE8tilSqG+Tr8OvLC
	4v9mmJgFtwiYUONDc7OSxw4/Mi7RYipxvlYsFLgDVnwaTKuogSumwMAZq5PVTfiT8ZoaWrLAX5s
	245nDfKc4E/t5u/m+o7gATxnJiXum/rJIdu0gouszThYA8pHI/PMok46QFv6j/qs=
X-Received: by 2002:a17:90a:8902:: with SMTP id u2mr20160239pjn.96.1560161577563;
        Mon, 10 Jun 2019 03:12:57 -0700 (PDT)
X-Received: by 2002:a17:90a:8902:: with SMTP id u2mr20160191pjn.96.1560161576785;
        Mon, 10 Jun 2019 03:12:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560161576; cv=none;
        d=google.com; s=arc-20160816;
        b=qA0E5jr3ZFsHno3L0CpXucsngztKYB7g5cB3qKmhZ2jtGVjJtICSxg5muxcAf92dGH
         y3MMWwEYDNwmIZfE7hyU1kuWMEkTgkgp4y3mA7njR4bYPvdW8LGMecW8H/hvuR9CzjD6
         kVhaEFwA8OB+pHp9fNi1ppkI9SB/UFOih+7qSSh6O6L1FFgHU6mC9XUiUUuYNHMoj/L9
         w7sJzO/agTz4tIw6FU9ZVQq9cULeLlbnog3nm5rmCpXCglnYC7fY+E0J//OqcB9vn3x2
         75wDccGibzDFlVIfSP52veRu0tXQE3xOyuq6E6rjYx8nKPz4mrI0bO+NJmKAfy9sFgbg
         KPbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=UpQZyxDAIZssxN7CCNuXeFikhiebMI4lHnTfzcrIiyQ=;
        b=IkktrrlHEqVn4Sf9zGvQmMgXnzwfrYGjAuIPTEq0fzxlpNEvPnW213kd98X7scDi2N
         8jaPxaaU5/g4dEV0xRfNlB2J7u5DAQ/oLcMBTgmV7F+4DrD3M0yc/EMXxbQc9JVzD+8E
         QFE+kAmEydoTxASOK4yKswFwO2/RQxfnqe82xyrLoqDYm7DX9deK0q686/Da2I5e5rEo
         Nk7pJeZl49Q2W3J1ztFymexgVI0q9Uu+ubZkiGwphcd4T5uKSRAwteQUtFM5Za2inGVc
         P8mYDMgMAoiShnuqq8X8DFt9SpJ5Srb+6ReD+GNxpEeB5eDGE0hxSwAXSKA78qCXc08l
         OJQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oT3Tgck9;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q62sor5610567pjb.10.2019.06.10.03.12.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 03:12:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oT3Tgck9;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UpQZyxDAIZssxN7CCNuXeFikhiebMI4lHnTfzcrIiyQ=;
        b=oT3Tgck9UOkWtTtrfEsTEc4PpMFYNC/1A+9ozR6V61Qzvmi8PU2PjmGz4nMCuGml3v
         H+nRmhJEBftdYa/jqjOOUDmFd3EIVk3K904sggw8sHSKT+izqm8D6xXryQtEqRIQwnYd
         kU6ue4gFnzw7c/7zfEq/nYUufkOUwE5mNFwKPN0SwyZ0Bbo4EwOKD09zGiKkw9lzRU0r
         8oiPkxnTLIkCVg18tdGUfuEWKg8MvK4yGM9BSlB9tZo15gQMiOojbos6lEuAFQ2aqnVh
         0TER9J8ovskikTwRLLABwQfJ8LIMQIbDXfzkiMaWGpOOhtsIYly64d/JTpyUpvwp9twe
         /YWQ==
X-Google-Smtp-Source: APXvYqzJUiyDWi8zaR4iqoYas4PnR+FTZYDwdV0l9Fr4aNPkQh14eZq3enRj6HzBCVUi/S2a/0C2XQ==
X-Received: by 2002:a17:90a:3787:: with SMTP id v7mr10962360pjb.33.1560161576370;
        Mon, 10 Jun 2019 03:12:56 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id l38sm9533673pje.12.2019.06.10.03.12.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 03:12:54 -0700 (PDT)
Date: Mon, 10 Jun 2019 19:12:48 +0900
From: Minchan Kim <minchan@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, hdanton@sina.com
Subject: Re: [RFCv2 4/6] mm: factor out madvise's core functionality
Message-ID: <20190610101248.GD55602@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-5-minchan@kernel.org>
 <20190531070420.m7sxybbzzayig44o@butterfly.localdomain>
 <20190531131226.GA195463@google.com>
 <20190531143545.jwmgzaigd4rbw2wy@butterfly.localdomain>
 <20190531232959.GC248371@google.com>
 <20190605132728.mihzzw7galqjf5uz@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605132728.mihzzw7galqjf5uz@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oleksandr,

On Wed, Jun 05, 2019 at 03:27:28PM +0200, Oleksandr Natalenko wrote:
< snip >
> > > > > >  	write = madvise_need_mmap_write(behavior);
> > > > > >  	if (write) {
> > > > > > -		if (down_write_killable(&current->mm->mmap_sem))
> > > > > > +		if (down_write_killable(&mm->mmap_sem))
> > > > > >  			return -EINTR;
> > > > > 
> > > > > Do you still need that trick with mmget_still_valid() here?
> > > > > Something like:
> > > > 
> > > > Since MADV_COLD|PAGEOUT doesn't change address space layout or
> > > > vma->vm_flags, technically, we don't need it if I understand
> > > > correctly. Right?
> > > 
> > > I'd expect so, yes. But.
> > > 
> > > Since we want this interface to be universal and to be able to cover
> > > various needs, and since my initial intention with working in this
> > > direction involved KSM, I'd ask you to enable KSM hints too, and once
> > > (and if) that happens, the work there is done under write lock, and
> > > you'll need this trick to be applied.
> > > 
> > > Of course, I can do that myself later in a subsequent patch series once
> > > (and, again, if) your series is merged, but, maybe, we can cover this
> > > already especially given the fact that KSM hinting is a relatively easy
> > > task in this pile. I did some preliminary tests with it, and so far no
> > > dragons have started to roar.
> > 
> > Then, do you mind sending a patch based upon this series to expose
> > MADV_MERGEABLE to process_madvise? It will have the right description
> > why you want to have such feature which I couldn't provide since I don't
> > have enough material to write the motivation. And the patch also could
> > include the logic to prevent coredump race, which is more proper since
> > finally we need to hold mmap_sem write-side lock, finally.
> > I will pick it up and will rebase since then.
> 
> Sure, I can. Would you really like to have it being based on this exact
> revision, or I should wait till you deal with MADV_COLD & Co and re-iterate
> this part again?

I'm okay you to send your patch against this revision. I'm happy to
include it when I start a new thread for process_madvise discussion
after resolving MADV_COLD|PAGEOUT.

Thanks.

