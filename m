Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E7ECC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 17:44:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1405C20656
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 17:44:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="H8OQnYnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1405C20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A60E8E009D; Wed,  9 Jan 2019 12:44:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9556F8E0038; Wed,  9 Jan 2019 12:44:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8447E8E009D; Wed,  9 Jan 2019 12:44:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5475A8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:44:41 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id q82so4229392ywg.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:44:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=favChGVhwPSbb8qcnD+cylPo0WpvRGC/2kNhSiLoKK8=;
        b=qrMtMWG65jrBBjr3iN3GNtggPkvcXeH1bc/rnavLRkdlBSjnpo19Zl42F45hoMl0YP
         UZKQqafoEkMUrU2txT0gbeBJLWuyeHwgJrzb3yI4QSsE4SZci3gVQfB88f2cibDgADia
         f15UtmmbQ4rt1UxzyplXpwct1KkPX5fyNseP8g09ORckc4DYYRmb7O77Es4AenM6Aw0w
         evS9eGp8WO7PYxKlgg2/iC+yNWNcZXPKVMUbPuz5R5ay9EEXNIxlfeouRwPF7Pmzm/UF
         4UGx7saseUOWoLh8fkfRAevD1waW9Cd8NaAkZm2QViJTnlCbbCCnwYOik9VD3dhT4j+c
         TpzA==
X-Gm-Message-State: AJcUukf8cjvKEl7Rw7i8s8R8JEnmoC1SOBAGWTnklhgXQsGM6eHJPGsC
	6et+3WF+fQ53fdoMmJVPcV9+h3Xm5OHr/NAuTAf0t+AJhuuUFIP3uOmkagYnm72dgv0FvDUk1GM
	z5p5E1EtnbSJ0pBSuzcht/XvJmiJ6XEJmIO5djw6+3nSvGU9D7cWTyVMrtkAaivmm5hrKgDVs9z
	yW1Y3J1FsKzUIf686z3Gl9LmMXw+QJNxJ7/cp84rg5xmj6yOQjzuajOnlFx30s7EMDdOkKnnU7L
	V6tP6dLeUl32iU2Rqn1WT8vs/Sq3uw2cK7oVO5XlmalyLad98+frmGrq/jq9DyffEN6EQXrRYjZ
	6ulzAoDiCWkWNlxk2Yi7Mb/skKjyR3zaF+NORZWChVdB/3hoQrsb0TD6PB9W3CZZNWSyS4LUAEi
	i
X-Received: by 2002:a81:b548:: with SMTP id c8mr6573105ywk.414.1547055881050;
        Wed, 09 Jan 2019 09:44:41 -0800 (PST)
X-Received: by 2002:a81:b548:: with SMTP id c8mr6573057ywk.414.1547055880265;
        Wed, 09 Jan 2019 09:44:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547055880; cv=none;
        d=google.com; s=arc-20160816;
        b=NRmmnucZ1tJAgKn4XZexIqaecbadfF60unVe5r9cAGFzu73Mnu9qcU84vrhsnITzt7
         e2WoiqUpV4Cm0aFcfruslKtvSqqsZm6W2NS3T72LaZ/l0r1eAdKo8TI7HNJQwPk/PcKK
         PmSfarEfzGYcIgy41tAcsuIXx62d5bU4Drz2TxLPCUv+hyDcSFBkX/yz/W/R9hB5zDtb
         8n26rY7GZgLYZcAzwtW+aBX2u8+nq532r6QP0/2UNXIcakbXHub79TiDqFCh+TUQ4BlJ
         ZZIe2U5wBIFzk8q2wLSzIa6XCPwmrFzrPjIUGOP8THz3KSWYMWMj9SqAXo5/ufmzvpW5
         G1dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=favChGVhwPSbb8qcnD+cylPo0WpvRGC/2kNhSiLoKK8=;
        b=F+I+3M25EJe5oTBdw3zBi0+5/R+H1yd0YW4A7qmnkPA0N6qkZCIoDx/IO79QeMgW1C
         t3W3DrZOHFKBO+5b3fOCcjfOMRHNlnLcNQw6tHP42hjsWAr+9G6CsR2TDAc99seMLeT2
         U0WJhDhX3WkorGHVkub/RjZ0HXg1SiUqndd5Jm5NXy/7kbFzR1BBgvLtJxOosQH9iQJV
         HI3dfC5T7IUbfeMi8sSFZFgyBYQYAGI7KLgvDVUIuMVS8VvJlYMOr3a0qv/mit2N5Z4/
         MkIYllqZW8XMLDnp94vaF86WLyUxEnRvPsbo+V4FWvwA0cyOwKNrvemx50qb4JiMp3WJ
         oiug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H8OQnYnD;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c143sor13042031ywb.153.2019.01.09.09.44.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 09:44:40 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H8OQnYnD;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=favChGVhwPSbb8qcnD+cylPo0WpvRGC/2kNhSiLoKK8=;
        b=H8OQnYnDpT/QD8T010mYLe6weU82h+c6bUshO5RhL5vAF554uG6GZy8gWGa/3gfk3A
         nRuMdujfUO9i70TZ6N/RN/xV5IIAKoHUnw660UAZj+DX8C9BKGe6HkFU1WllF3x/wmm+
         swls2lbw927qvQwGYx0s29w7oefWC+1LSRZBy2JJj682ePp/b3mdRbG74WSZNF78WxAG
         6MlXRKuS44x6JrmgflIOiMtVd5XrUiq7sJRyvZx5fFj1GoRdpSP8LU6n6sJFrpBWmQO0
         KK7MYHv6ZAg5OTUACAhCRn76t1JjuTE3xrKeeOMGcHmrWHtejxUi3laCB6hSlFpoNgvL
         4xhw==
X-Google-Smtp-Source: ALg8bN6d/oyAgE1SsVMquCcmplKjV3fcMFFf2qQhTjrnsWOVChTiErE/N9s3RtyErKsK5O76BDVaLqahikxnhHqrQM8=
X-Received: by 2002:a0d:e4c5:: with SMTP id n188mr6537504ywe.349.1547055879675;
 Wed, 09 Jan 2019 09:44:39 -0800 (PST)
MIME-Version: 1.0
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <20190109164528.GA13515@cmpxchg.org>
In-Reply-To: <20190109164528.GA13515@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 9 Jan 2019 09:44:28 -0800
Message-ID:
 <CALvZod6P12gUq-xTZ1V4ZBeFXGE6dGAfA5uiw6iN1w14eP9j2Q@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, 
	josef@toxicpanda.com, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109174428.X2Vx1NKONDfWpa-o-4Yc7ndXm-KIczFBExBkK4rqw6U@z>

Hi Johannes,

On Wed, Jan 9, 2019 at 8:45 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Wed, Jan 09, 2019 at 03:20:18PM +0300, Kirill Tkhai wrote:
> > On nodes without memory overcommit, it's common a situation,
> > when memcg exceeds its limit and pages from pagecache are
> > shrinked on reclaim, while node has a lot of free memory.
> > Further access to the pages requires real device IO, while
> > IO causes time delays, worse powerusage, worse throughput
> > for other users of the device, etc.
> >
> > Cleancache is not a good solution for this problem, since
> > it implies copying of page on every cleancache_put_page()
> > and cleancache_get_page(). Also, it requires introduction
> > of internal per-cleancache_ops data structures to manage
> > cached pages and their inodes relationships, which again
> > introduces overhead.
> >
> > This patchset introduces another solution. It introduces
> > a new scheme for evicting memcg pages:
> >
> >   1)__remove_mapping() uncharges unmapped page memcg
> >     and leaves page in pagecache on memcg reclaim;
> >
> >   2)putback_lru_page() places page into root_mem_cgroup
> >     list, since its memcg is NULL. Page may be evicted
> >     on global reclaim (and this will be easily, as
> >     page is not mapped, so shrinker will shrink it
> >     with 100% probability of success);
> >
> >   3)pagecache_get_page() charges page into memcg of
> >     a task, which takes it first.
> >
> > Below is small test, which shows profit of the patchset.
> >
> > Create memcg with limit 20M (exact value does not matter much):
> >   $ mkdir /sys/fs/cgroup/memory/ct
> >   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
> >   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
> >
> > Then twice read 1GB file:
> >   $ time cat file_1gb > /dev/null
> >
> > Before (2 iterations):
> >   1)0.01user 0.82system 0:11.16elapsed 7%CPU
> >   2)0.01user 0.91system 0:11.16elapsed 8%CPU
> >
> > After (2 iterations):
> >   1)0.01user 0.57system 0:11.31elapsed 5%CPU
> >   2)0.00user 0.28system 0:00.28elapsed 100%CPU
> >
> > With the patch set applied, we have file pages are cached
> > during the second read, so the result is 39 times faster.
> >
> > This may be useful for slow disks, NFS, nodes without
> > overcommit by memory, in case of two memcg access the same
> > files, etc.
>
> What you're implementing is work conservation: avoid causing IO work,
> unless it's physically necessary, not when the memcg limit says so.
>
> This is a great idea, but we already have that in the form of the
> memory.low setting (or softlimit in cgroup v1).
>
> Say you have a 100M system and two cgroups. Instead of setting the 20M
> limit on group A as you did, you set 80M memory.low on group B. If B
> is not using its share and there is no physical memory pressure, group
> A can consume as much memory as it wants. If B starts and consumes its
> 80M, A will get pushed back to 20M. (And when B grows beyond 80M, they
> compete fairly over the remaining 20M, just like they would if A had
> the 20M limit setting).

There is one difference between the example you give and the proposal.
In your example when B starts and consumes its 80M and pushes back A
to 20M, the direct reclaim can be very expensive and
non-deterministic. While in the proposal, the B's direct reclaim will
be very fast and deterministic (assuming no overcommit on hard limits)
as it will always first reclaim unmapped clean pages which were
charged to A.

thanks,
Shakeel

