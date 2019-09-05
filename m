Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5697C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:07:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E32E220692
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:07:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fEPR9+4F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E32E220692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A6376B0003; Thu,  5 Sep 2019 16:07:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457BE6B0005; Thu,  5 Sep 2019 16:07:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344AC6B0007; Thu,  5 Sep 2019 16:07:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC6B6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:07:43 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A4F07181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:07:42 +0000 (UTC)
X-FDA: 75901952364.30.baby89_90f27192884b
X-HE-Tag: baby89_90f27192884b
X-Filterd-Recvd-Size: 7917
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:07:42 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id k20so3014046oih.3
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 13:07:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6k7PZuJzGWrD6r0C7js2ghL9hn4vXg63+nMGa3lc03Q=;
        b=fEPR9+4FnJ/Wuh5lAs7l0q7dg8u+29rxGa1vObZGAYxHLXpMJmWtvQm0WI7yFHpbA9
         sotwZ5fvHtmhbOOjsGD4XdRWAE+6AYb3s0hVUcTs0ij1ac4cvAJs5swoW2m9fu57OadR
         o7BrkXPdVisi/74Qj4Up0mSJKh8d9sLEmWMfy0aV0iHYtAC5JGXFYDT9kmIBY8JKcNFQ
         WvzUvTWDjYTc+t0UA+BITLbIMNqKrTmCn661eeX0fPI9t70tskNE478AIBdUgubiXhlJ
         3kroS/4vY/n8ro+zwulHYVAcsEsu6RBGxZdPvkeg1EPaxxG7BNg55LP1WNtcedAtAJlo
         YeMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=6k7PZuJzGWrD6r0C7js2ghL9hn4vXg63+nMGa3lc03Q=;
        b=ifaBj9JOxfFeM1iO6cdtikOgnhpAzKi20rH8Aqq14B4fxZEyGuphD6yhEiBEd0rEyd
         WuC4WBY2lA9Xa5MV3DunalYtpU29RpPAkvGf2VNTQAeC7zv4X/xXBYsQZWyvM/db+qE/
         N151n9aG9AAmXMOE+gsvEKkUypLjdOleEeSzHv6DId7Ebd8vgh+SqjD2TOpsQCCRUxZ3
         tFLqIuF5G86hE74urnveu0P3LNo1zkvc6jczKjLbcTxoOJTxlmvbMHbgr1zSglf5sPJO
         9Nd/CIC7HQu8vD30W+5uBSTjgwu11BJgPA4hhDINs374MY868tKUEIhMyxvAbPvjz7Pq
         gQyA==
X-Gm-Message-State: APjAAAURiGexzjN8m7wBclUdOQt/mBLN4lReW8sFHYT+SJoI5OiP3XK0
	V9GXqR6GPOC4E1VUDyv7VNRZcH1TPCIWaE3V+p1CHA==
X-Google-Smtp-Source: APXvYqzyY+dI8j4oksYtUG/bs6k+iiXfYPjfr4iAtUt+sQklxzS+bW2yptWP0sznueZLxU0tmkvtO8vWY8nAzmtJJEY=
X-Received: by 2002:aca:da86:: with SMTP id r128mr4287079oig.103.1567714061086;
 Thu, 05 Sep 2019 13:07:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190826233240.11524-1-almasrymina@google.com>
 <20190828112340.GB7466@dhcp22.suse.cz> <CAHS8izPPhPoqh-J9LJ40NJUCbgTFS60oZNuDSHmgtMQiYw72RA@mail.gmail.com>
 <20190829071807.GR28313@dhcp22.suse.cz> <cb7ebcce-05c5-3384-5632-2bbac9995c15@oracle.com>
 <e7f91a50-5957-249c-8756-25ea87c77fc4@oracle.com>
In-Reply-To: <e7f91a50-5957-249c-8756-25ea87c77fc4@oracle.com>
From: Mina Almasry <almasrymina@google.com>
Date: Thu, 5 Sep 2019 13:07:30 -0700
Message-ID: <CAHS8izMCA9+sY+dxHxuFgANCLD2oNznPqGYvi1+C2xOkv=7EYw@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, shuah <shuah@kernel.org>, 
	David Rientjes <rientjes@google.com>, Shakeel Butt <shakeelb@google.com>, 
	Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com, 
	open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>, 
	Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 4:46 PM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> On 9/3/19 10:57 AM, Mike Kravetz wrote:
> > On 8/29/19 12:18 AM, Michal Hocko wrote:
> >> [Cc cgroups maintainers]
> >>
> >> On Wed 28-08-19 10:58:00, Mina Almasry wrote:
> >>> On Wed, Aug 28, 2019 at 4:23 AM Michal Hocko <mhocko@kernel.org> wrote:
> >>>>
> >>>> On Mon 26-08-19 16:32:34, Mina Almasry wrote:
> >>>>>  mm/hugetlb.c                                  | 493 ++++++++++++------
> >>>>>  mm/hugetlb_cgroup.c                           | 187 +++++--
> >>>>
> >>>> This is a lot of changes to an already subtle code which hugetlb
> >>>> reservations undoubly are.
> >>>
> >>> For what it's worth, I think this patch series is a net decrease in
> >>> the complexity of the reservation code, especially the region_*
> >>> functions, which is where a lot of the complexity lies. I removed the
> >>> race between region_del and region_{add|chg}, refactored the main
> >>> logic into smaller code, moved common code to helpers and deleted the
> >>> duplicates, and finally added lots of comments to the hard to
> >>> understand pieces. I hope that when folks review the changes they will
> >>> see that! :)
> >>
> >> Post those improvements as standalone patches and sell them as
> >> improvements. We can talk about the net additional complexity of the
> >> controller much easier then.
> >
> > All such changes appear to be in patch 4 of this series.  The commit message
> > says "region_add() and region_chg() are heavily refactored to in this commit
> > to make the code easier to understand and remove duplication.".  However, the
> > modifications were also added to accommodate the new cgroup reservation
> > accounting.  I think it would be helpful to explain why the existing code does
> > not work with the new accounting.  For example, one change is because
> > "existing code coalesces resv_map entries for shared mappings.  new cgroup
> > accounting requires that resv_map entries be kept separate for proper
> > uncharging."
> >
> > I am starting to review the changes, but it would help if there was a high
> > level description.  I also like Michal's idea of calling out the region_*
> > changes separately.  If not a standalone patch, at least the first patch of
> > the series.  This new code will be exercised even if cgroup reservation
> > accounting not enabled, so it is very important than no subtle regressions
> > be introduced.
>
> While looking at the region_* changes, I started thinking about this no
> coalesce change for shared mappings which I think is necessary.  Am I
> mistaken, or is this a requirement?
>

No coalesce is a requirement, yes. The idea is that task A can reseve
range [0-1], and task B can reserve range [1-2]. We want the code to
put in 2 regions:

1. [0-1], with cgroup information that points to task A's cgroup.
2. [1-2], with cgroup information that points to task B's cgroup.

If coalescing is happening, then you end up with one region [0-2] with
cgroup information for one of those cgroups, and someone gets
uncharged wrong when the reservation is freed.

Technically we can still coalesce if the cgroup information is the
same and I can do that, but the region_* code becomes more
complicated, and you mentioned on an earlier patchset that you were
concerned with how complicated the region_* functions are as is.

> If it is a requirement, then think about some of the possible scenarios
> such as:
> - There is a hugetlbfs file of size 10 huge pages.
> - Task A has reservations for pages at offset 1 3 5 7 and 9
> - Task B then mmaps the entire file which should result in reservations
>   at 0 2 4 6 and 8.
> - region_chg will return 5, but will also need to allocate 5 resv_map
>   entries for the subsequent region_add which can not fail.  Correct?
>   The code does not appear to handle this.
>

I thought the code did handle this. region_chg calls
allocate_enough_cache_for_range_and_lock(), which in this scenario
will put 5 entries in resv_map->region_cache. region_add will use
these 5 region_cache entries to do its business.

I'll add a test in my suite to test this case to make sure.

> BTW, this series will BUG when running libhugetlbfs test suite.  It will
> hit this in resv_map_release().
>
>         VM_BUG_ON(resv_map->adds_in_progress);
>

Sorry about that, I've been having trouble running the libhugetlbfs
tests, but I'm still on it. I'll get to the bottom of this by next
patch series.

> --
> Mike Kravetz

