Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2356C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A94322133F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:44:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OXrfO0e3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A94322133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A4A06B026E; Tue, 28 May 2019 07:44:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 554966B026F; Tue, 28 May 2019 07:44:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4446B6B0272; Tue, 28 May 2019 07:44:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8DF6B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:44:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d125so12398618pfd.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Na+J22i77Z4lW2CgfdPS10rXWxVdK/zIAtW3TAGkfc0=;
        b=Ys2cJrO88v6bdf0PIZJazya9rbB3cHXrY46J0fNe3hKAes20XpKuPNP0vzqfKF8DPT
         8R3hw125pqXsKD5U4HVcBUJQOGkAQGyQylBT15704q19CTQhcyc6tMuS1V9Pk6DLiRh6
         4Wo1qnidVlctFjZxraXtNartvLcaB5VDx5JqSFIrPLfinuA5c7nFkayTpCSl4B+KrDjZ
         VZSoED/SqMXqIuNJSKNf8lBtA0gfJYEMsS7j1zR0hjLA6Y+gU8mxSzmxcwJZo49/7cCy
         kYeia23GnsuyPswBVfmQ2KtW6FbKMOqlOQKQY0YV737PSGrV6eYG36lqRXNeRs2W9aBB
         GkVg==
X-Gm-Message-State: APjAAAXRumdz9Om6T9vtVu7NKQZIUv1ZWEXZfbA5jkf11UiScbdu+6fT
	VyEhhu6ZZhrNjawKr3SgcwnXAqQ511eMGZwU03Y5XYLGn1LISNjV8jPkwTnjmZYA/bhgAk22Aza
	zTSm0zfcL3QM597ZSHfWg8Za7wh3tDZ+ZKjbOkHR30CuLmTT22ttualOkMUaQ1ro=
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr19185719pla.33.1559043883687;
        Tue, 28 May 2019 04:44:43 -0700 (PDT)
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr19185660pla.33.1559043882980;
        Tue, 28 May 2019 04:44:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559043882; cv=none;
        d=google.com; s=arc-20160816;
        b=q1YCFGzrw6x0sevO2Q0zbvwCA+Bp5unwv74DmASRF824Rgxsr0QX4ap7DEcRC7NcUH
         AfmGlBynjxcX0KN3fe7OPxnrHNgQAP6rceMbvaUHzGtwGBSFZaZYavE4PGfL2sTep4Wx
         iqs70BMIisaxa9oJ6YhLl5lVV/0yzzNLzeee/Vl9G3AuuEsB+abOp6k/HLB1/K8FGeYE
         Zf1YSqIMPeZvPf/pCII2xbiGB1IDcovANuyb1Vfk/K0Q1eYPZCbc15n5HxME/mQuWdS0
         8PKBeEmQvJivTL05DI9ZMUgDrxuUVzRzGammkB65cjEoBnOtCtszwVHtXskTDBz8VyJF
         N6uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Na+J22i77Z4lW2CgfdPS10rXWxVdK/zIAtW3TAGkfc0=;
        b=CWt2LGBRgxn95uqlci4vLrupW6NXPpaBweVjJ3Rk0U0JcF98i1TaIZIVFtooF44L2X
         ipJX5ouqoEFFsrkj0VhgnTlGDd1M1ldfD1qB6l/iwXbR1qBb5murSFRSZhTu3AX5zmye
         ANKi9CwN5Zjs1gbqDsiPuy2NsHP+1nAShhCPJ3qoV1IUrLPYYKMk39i/7q6l/XOLRUeQ
         L0jUKZG4zxruF9x7i7GP2PEuIw3F2nMl0t+XQZsfjWAnOaYfQwj5PVqtQ1TgsHHLIphE
         hb9mm+mY6ZAauzlXZ2OR7U7rRNBfZunGfSaPrtLvGKWQSipwx9uRh+ee+3dzPe8YPTkJ
         pElA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OXrfO0e3;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21sor3265495pgh.0.2019.05.28.04.44.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 04:44:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OXrfO0e3;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Na+J22i77Z4lW2CgfdPS10rXWxVdK/zIAtW3TAGkfc0=;
        b=OXrfO0e3RlFaNQy3MzONif4phiuHMCrfpnn6bbGelKBttsjDb7M44ZI+FJjgbUxw6f
         7vXbGVdyuku1hUT89ULnYttsb2u5kz+/BF/U8tcBofrdT60RhDF7fwu4ghS6H7ZfsAJa
         FZ50GaZ9uRRD7wN2LYuLslXoDyELhO8unuwv8Xwg3UAse7oMSN4FPEALNexObmpuMFW/
         5tA/FWmvQH7GohrjdijN5eSt6qT+A7WGKgpjeoFVUudB1fizEiT481PdyYQ3Z5oxZlmg
         byTjYxHrYSLJKGsm3NO5UVkJkblMmBrgaHfU+8U+83lHzKF6n4q9it0LigqhyMDCjINY
         getA==
X-Google-Smtp-Source: APXvYqxKdDbXQTCQ2wTlaKWGq9gz76gsK2o3fQBBvCu+KCLAp37410V79lyMGOqtSpKnkp3QPk1hFQ==
X-Received: by 2002:a65:5206:: with SMTP id o6mr1937077pgp.248.1559043882565;
        Tue, 28 May 2019 04:44:42 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id v4sm8549594pfe.180.2019.05.28.04.44.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 04:44:41 -0700 (PDT)
Date: Tue, 28 May 2019 20:44:36 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528114436.GB30365@google.com>
References: <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528112840.GY1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 01:28:40PM +0200, Michal Hocko wrote:
> On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > >
> > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > 
> > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > e.g., Android memory map debugging commands.
> > > > > > 
> > > > > > I agree it's the best we can get *generally*.
> > > > > > Michal, any opinion?
> > > > > 
> > > > > I am not really sure this is directly related. I think the primary
> > > > > question that we have to sort out first is whether we want to have
> > > > > the remote madvise call process or vma fd based. This is an important
> > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > so far unfortunately.
> > > > 
> > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > but thought it could be easily extended later for each address range
> > > > operation as userspace getting smarter with more information.
> > > 
> > > Never design user API based on a single usecase, please. The "easily
> > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > several times, the synchronization model has to be thought through
> > > carefuly before a remote process address range operation can be
> > > implemented.
> > 
> > I agree with you that we shouldn't design API on single usecase but what
> > you are concerning is actually not our usecase because we are resilient
> > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > Actually, many hints are already racy in that the upcoming pattern would
> > be different with the behavior you thought at the moment.
> 
> How come they are racy wrt address ranges? You would have to be in
> multithreaded environment and then the onus of synchronization is on
> threads. That model is quite clear. But we are talking about separate

Think about MADV_FREE. Allocator would think the chunk is worth to mark
"freeable" but soon, user of the allocator asked the chunk - ie, it's not
freeable any longer once user start to use it.

My point is that kinds of *hints* are always racy so any synchronization
couldn't help a lot. That's why I want to restrict hints process_madvise
supports as such kinds of non-destruptive one at next respin.

> processes and some of them might be even not aware of an external entity
> tweaking their address space.
> 
> > If you are still concerning of address range synchronization, how about
> > moving such hints to per-process level like prctl?
> > Does it make sense to you?
> 
> No it doesn't. How is prctl any relevant to any address range
> operations.

"whether we want to have the remote madvise call process or vma fd based."

You asked the above question and I answered we are using process level
hints but anon/vma filter at this moment. That's why I told you prctl to
make forward progress on discussion.

