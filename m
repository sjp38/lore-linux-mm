Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40475C43612
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:29:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A4520675
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:29:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="j8HwzKf4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A4520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31C168E0003; Wed, 16 Jan 2019 16:29:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CAC08E0002; Wed, 16 Jan 2019 16:29:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3158E0003; Wed, 16 Jan 2019 16:29:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF3B48E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:29:37 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w4so3613267wrt.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:29:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HJrfE3jaolNs6YKqdZtpYFmOvcf18H8OhY7pa4kzWEY=;
        b=MoKDB1LDqW540E/Phx6LKh5PWIvHkuIsZb215A3CkZpUUe7W8NHsxsjCCm5CmRN+YX
         16i5Wl9bYsfUVdjSr+Ebt9+Tkf7ftDOlGb3sEOHNFT4xI9HZrB15ko+8M2wdwm8EQJgk
         M0vcomkvAxxE9CydQj2sucMoD9i97v7+ytsUKaasJWQcGBB9O6hlOwRxZNtCM17O0Qje
         E/+NUxzgppqW2hStrcpPc7h77MDUcN/V1Zy4/dQcYkDkBT7MhIyzPp7RlUatg32rml70
         l2qcxn1ZbDF30iDl2+TprDYsmfJyEn/xAkEyrqchbm6m7mEwgIWJCLPzwkX4yTGrTkFR
         ARRg==
X-Gm-Message-State: AJcUukf3BzC1y23o3vr8ZLU6Yx8D4DCNM1+61as8nGpktWKkpgXS70ca
	ppzkFuAPRwEbwn6y+6m/cdD63YELu0JpHgnZ9KsHsU6vJk5YQkuCG9sbcCBS8qIQq9E6PF0A8BD
	3mj9jppkFfo62JkdxwdHnUM4X3C/eXE7XVNVeUZNDCWA/RmrmWk1fED8+yGnjqaG5OnpJT/K0wV
	l5FDR4f3uQHbHWS7UujYKUKpBJ87j4FdxwmBowx4q7Zd6JpbnQ3gkhe1lc6usQZz4Ux1Au/5XdS
	/yyTYMDRSyc3Q7Bj3mPnIEAenx5A8d3DLQzx8zQq0d1Zk8xlrD02hXW7qc9iZuFwzcplHH5nwR4
	3Qxzgz+1t2eLkdnsvpld56FJeLXYIQmHvwtC0gH+kLMg9eyUTWJTIhlnLkj+Cyu2uzyO389uKyF
	T
X-Received: by 2002:a1c:8f95:: with SMTP id r143mr8649490wmd.65.1547674177236;
        Wed, 16 Jan 2019 13:29:37 -0800 (PST)
X-Received: by 2002:a1c:8f95:: with SMTP id r143mr8649447wmd.65.1547674175938;
        Wed, 16 Jan 2019 13:29:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547674175; cv=none;
        d=google.com; s=arc-20160816;
        b=zCnVv17TO58FQ0G1Gqx4iajrlhBc8SBFaxwBq3JZxDn6/4I15cium8QrlxihI42Den
         QeWQ9r7G5NlvlSTETWQVmNmbmTgz3cc+gA7v5uBXWnpm/kAhJko5MuEQ9Ffx05qsjQP4
         gTm1fTOgMGIvrZwNznb82aPt/LpGrWZUHi0sEtik9iN0OAaZjZgCb722aHbD0BKpPIvU
         K09IyAa9CiwIyWPxi4xQsyqgeJElHEmmeXsXncDHq/2ml7jOBZgxeRKAB/bOMsv6P6u9
         4aO7NCOZ3TeRBvIroLOLaUyR4SMGM17wXHItKeoBJjGLLbaOKHkpEgo9kyFEOHeoVZlf
         dVsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HJrfE3jaolNs6YKqdZtpYFmOvcf18H8OhY7pa4kzWEY=;
        b=rkweIlLTbiwPtrTDmQUlVvhOL+2Ne4o/r7YGqSDZJsHD99PIv/RiOl0A48s9pHtxwV
         SW/eyhlzTLquKxJsaLcYANtyM8LgpfYa7uYs0wtVpTvJEbLRUIpaVoURibjRLf6Nwmfv
         cHBGvbEMOnd0bMP86h69rwju5L773kzJ+brw94wOHVwKSrZcf4aYWi4vdzb2oaalNSmA
         lsE4S/5pvN72ePs2pqgfd6ijEftdWmAirU4RxvHU0LLZ8TT89HojPEQkI0UqL4Ip3o0x
         XyuCmboZzddcbFQPNjPzYjVAVvZjbN/y/Q9+DnNLvA37F6rcN4ILUjVOxJAnfxDl/00C
         pAEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=j8HwzKf4;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor54359883wrs.49.2019.01.16.13.29.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:29:35 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=j8HwzKf4;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HJrfE3jaolNs6YKqdZtpYFmOvcf18H8OhY7pa4kzWEY=;
        b=j8HwzKf4QtGnl55VhWxxU62RJz2zdHqwwXdAJtf4r17Cb5i4Z9PTr3LYowNmAp7bfs
         +ORL7QKVLtsnXsxfog2gfV4zCd8b0Lp/hBynHbSFCWHpsjhb+gUzSAD4s6BHH/fRV6pB
         Y8RKIyku/qvSySJPfI4lQbUHofvTuiB69SAxZnEm2/M1qYVOb6tzofxI8DeoSsxlVo+u
         nZ82jRaDZ+i/eUXJAlQsvkLtbuNxntHHswTgQKdk/B7zvICxLyY6D2dBF/Yx3CINZzCc
         r7EEDIuZ1ahCWCcTqQtXrHreZMO0rz9tVS/ldkSGVBMgfPl+UDSbYYc4Q+A3wO26h8wa
         jfTw==
X-Google-Smtp-Source: ALg8bN41+hamEJqjA/ErW04qKhyfcdryU7d5AEi8xni3wtZ/EgC/cnBgZaQBeIjpdJCyR0mVUw9KZOn/xGVSOsdGr5g=
X-Received: by 2002:adf:de91:: with SMTP id w17mr9843729wrl.320.1547674175412;
 Wed, 16 Jan 2019 13:29:35 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
 <20190116132446.GF10803@hirez.programming.kicks-ass.net> <CAJuCfpEJW6Uq4GSGEGLKOM4K7ySHUeTGrSUGM1+EJSQ16d8SJg@mail.gmail.com>
 <20190116191728.GA1380@cmpxchg.org> <20190116192744.GA1576@cmpxchg.org>
In-Reply-To: <20190116192744.GA1576@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 16 Jan 2019 13:29:24 -0800
Message-ID:
 <CAJuCfpG1+=XXS=7oTaBw_J9cGvmheTDrr3jv8UxBThwa4K+Dmw@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Tejun Heo <tj@kernel.org>, lizefan@huawei.com, axboe@kernel.dk, dennis@kernel.org, 
	Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, 
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116212924.8b2s8_0-tr-9DZBfF1VW36MTzw4QFxh7Rj837iBmmO8@z>

On Wed, Jan 16, 2019 at 11:27 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Wed, Jan 16, 2019 at 02:17:28PM -0500, Johannes Weiner wrote:
> > On Wed, Jan 16, 2019 at 09:39:13AM -0800, Suren Baghdasaryan wrote:
> > > On Wed, Jan 16, 2019 at 5:24 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > > >
> > > > On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> > > > > For memory ordering (which Johannes also pointed out) the critical point is:
> > > > >
> > > > > times[cpu] += delta           | if g->polling:
> > > > > smp_wmb()                     |   g->polling = polling = 0
> > > > > cmpxchg(g->polling, 0, 1)     |   smp_rmb()
> > > > >                               |   delta = times[*] (through goto SLOWPATH)
> > > > >
> > > > > So that hotpath writes to times[] then g->polling and slowpath reads
> > > > > g->polling then times[]. cmpxchg() implies a full barrier, so we can
> > > > > drop smp_wmb(). Something like this:
> > > > >
> > > > > times[cpu] += delta           | if g->polling:
> > > > > cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
> > > > >                               |   smp_rmb()
> > > > >                               |   delta = times[*] (through goto SLOWPATH)
> > > > >
> > > > > Would that address your concern about ordering?
> > > >
> > > > cmpxchg() implies smp_mb() before and after, so the smp_wmb() on the
> > > > left column is superfluous.
> > >
> > > Should I keep it in the comments to make it obvious and add a note
> > > about implicit barriers being the reason we don't call smp_mb() in the
> > > code explicitly?
> >
> > I'd keep 'em out if they aren't actually in the code. But I'd switch
> >
> >       delta = times[*]
> >
> > in this comment to to
> >
> >       get_recent_times() // implies smp_mb()
>
> Actually, I might have been mistaken about this. The seqcount locking
> does an smp_rmb() and an smp_wmb(), and that orders reads and writes
> respectively, but doesn't necessarily order reads against writes.
>
> So I think we need an explicit smp_mb() after all.

I see. So, the action items I collected so far:

1. Add a comment in the code next to cmpxchg() indicating implicit smp_mb.
2. Add explicit smp_mb after "g->polling = 0" and before "delta =
times[*]" both in the code and in the comments (in the slowpath).
3. Use atomic_t for g->polling. Add a note in the comments why atomic
operations are not needed in the slowpath.
4. Minimize line-breaks.

Please let me know if I missed anything, otherwise will make these
changes and post ver 3 of the patchset.
Thanks,
Suren.

