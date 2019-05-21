Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AB93C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9B402075E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:32:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ra87Jvwg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9B402075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B8166B0003; Tue, 21 May 2019 06:32:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 440BC6B0005; Tue, 21 May 2019 06:32:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC1A6B0006; Tue, 21 May 2019 06:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E41366B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:32:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a90so11120489plc.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:32:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iEpABD/nsZz33E7K8kq0g1PtAPqQkfDdFrRiuwAA8wE=;
        b=mUVErUJ++lB8h4ac8bqZ1YZlGyyYqTk1pAawaeOA0Loh0BWNHaM6w8rCxuiDoglZfD
         8jNEXUo96Sil+rINNkg7/db+3kj5cuzOK78zr28QFz1rm3XqV59NQK3ANqQW+aucA80u
         2yHteQiXYBjHoaDaChwrsdGGKQ9DbCkWT0oAFi0OYxsNDOdznDF1uL+DZwziuX4GTt+n
         YZAxyCr6O/pTURp+9L4SvX5OzlgJgZKZQXE+ETO2xxdbOgpJMXo1roR85hj49O0O9H2J
         fDkQu+ibCGSNOZmeVe8jlCGrFvDc8T1q/KtU6tRQat3BCYrA7JlQ1ti1ESGocaXXkCJw
         ZmwQ==
X-Gm-Message-State: APjAAAVsmlm5dTudjSymCZZuEFfNURw515YWp14jpPKFQGag9OMHIiQJ
	gyJbYLbxnenBNbfOyb8MpDa6RNy93TWjgUuEshLVq+qx/0ssIgh67GfmVRLas++cUoMP1hcntmP
	GNrik6uoaNgSt7otLfXR0pJJvthGkMfxaBK5yPDyyChnaOsL0qIQVzyG1l5RjbLE=
X-Received: by 2002:a63:78c6:: with SMTP id t189mr849573pgc.293.1558434752423;
        Tue, 21 May 2019 03:32:32 -0700 (PDT)
X-Received: by 2002:a63:78c6:: with SMTP id t189mr849433pgc.293.1558434750660;
        Tue, 21 May 2019 03:32:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558434750; cv=none;
        d=google.com; s=arc-20160816;
        b=R3pmtJdE+pcNBHmpGM5c1dlmofbG/R6AmDxp2cnAf8Vr4kePCFzW2PwiA4kNe6vPLz
         XUKor5RBDvjGRbZJmgZbdBIR77zyx4dIWS2/mrON6ulgkTOv97bwngdnXJA3HzIu5IMf
         FH80BWQWVsH3lkIXeoK+0wZqy3hVrDRk13hXw+tC0YQFKRTR5ST8RFdjwWxEeSM5vuNv
         cVHQJyhGb/23CTY1OWLu/+W0jBH2eRgzOaZnyiqIQNw4e/Pb/eDcdm3Hp97n6Itwl30L
         VaDOl2+rjbiSIEQCgsKlSNNR7PGsBYxMbFwSbXJ/QkJZfZ9zaZ68JE2YGYE4MytNlGq2
         KY5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=iEpABD/nsZz33E7K8kq0g1PtAPqQkfDdFrRiuwAA8wE=;
        b=yIkk4b/rjmYcea9OVsJ+xpuPix0DVwAKM6BsaVeV1AH+GmMCDyU5Dt2OclO6xh3a7C
         r6YIGqmkCz2ux21tnD/KlVurKWjPMcz93rwf1Ur2AsAAdQq0EQBB4Jck2lyxH+7Fe7oF
         H0GzqvNZydbxhaGQo1aUtN/+grG3AThtHBKxzeoP2YqcCfEo319HDDLNDSoUVtY3abJc
         IABxx5Xl3Cg2ipxBE9M7yHgM7A4/37wm31TRvbR5iLsaPcYfB5VsD2VpWVwBGLFofzoB
         OzU3lIFJ9x6z19LpuvpIsys27QUQOUr6z19wu1SzfDLpeU0H9PL64aEGXxLBEEvwybNh
         e1/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ra87Jvwg;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor9089863pgq.52.2019.05.21.03.32.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 03:32:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ra87Jvwg;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iEpABD/nsZz33E7K8kq0g1PtAPqQkfDdFrRiuwAA8wE=;
        b=ra87JvwgK/Zau+lFTPoxO3sEsrDEs7bq3v+sP8khYi/R1y9BVFkLV0dtEgBCALl1RC
         BvmEvtF2rbLRX5/jiSCOP+edg7XsEcCiVRRFaSnESZebX/VPzbmKlp/+aunsJ/v8Parl
         zrcdnW3a1IXgZk6c//4kQeR8tFYRhFUXYriqNaXMoWw0cDaMocbQgQA6Pcp4kd7G6HQZ
         T7MzDB7FhNfA6dyV0HLfz9g77EKMvjmYfEfy+E8AK6V/3RY2BW+5nn/dAdXYqXCi5hNU
         GBnMuqUhUnCSndbZX3Cg8l2DiU5iNOqkoMiMEqqSEluqMbZtYAdXTUJe05W+pf9dG8o8
         xwuA==
X-Google-Smtp-Source: APXvYqwiCEhrh1gNZKYql1ciR0mfuAlQeUIx5uOvluMiBVcOnNC/dxSyCtOOCo7BXHPxdLEX8zMfmQ==
X-Received: by 2002:a63:1212:: with SMTP id h18mr31397904pgl.266.1558434750297;
        Tue, 21 May 2019 03:32:30 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id k6sm24835382pfi.86.2019.05.21.03.32.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 03:32:29 -0700 (PDT)
Date: Tue, 21 May 2019 19:32:23 +0900
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
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190521103223.GD219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190520091829.GY6836@dhcp22.suse.cz>
 <20190521024107.GF10039@google.com>
 <20190521061743.GC32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521061743.GC32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:17:43AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 11:41:07, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 11:18:29AM +0200, Michal Hocko wrote:
> > > [Cc linux-api]
> > > 
> > > On Mon 20-05-19 12:52:52, Minchan Kim wrote:
> > > > There is some usecase that centralized userspace daemon want to give
> > > > a memory hint like MADV_[COOL|COLD] to other process. Android's
> > > > ActivityManagerService is one of them.
> > > > 
> > > > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > > > required to make the reclaim decision is not known to the app. Instead,
> > > > it is known to the centralized userspace daemon(ActivityManagerService),
> > > > and that daemon must be able to initiate reclaim on its own without
> > > > any app involvement.
> > > 
> > > Could you expand some more about how this all works? How does the
> > > centralized daemon track respective ranges? How does it synchronize
> > > against parallel modification of the address space etc.
> > 
> > Currently, we don't track each address ranges because we have two
> > policies at this moment:
> > 
> > 	deactive file pages and reclaim anonymous pages of the app.
> > 
> > Since the daemon has a ability to let background apps resume(IOW, process
> > will be run by the daemon) and both hints are non-disruptive stabilty point
> > of view, we are okay for the race.
> 
> Fair enough but the API should consider future usecases where this might
> be a problem. So we should really think about those potential scenarios
> now. If we are ok with that, fine, but then we should be explicit and
> document it that way. Essentially say that any sort of synchronization
> is supposed to be done by monitor. This will make the API less usable
> but maybe that is enough.

Okay, I will add more about that in the description.

>  
> > > > To solve the issue, this patch introduces new syscall process_madvise(2)
> > > > which works based on pidfd so it could give a hint to the exeternal
> > > > process.
> > > > 
> > > > int process_madvise(int pidfd, void *addr, size_t length, int advise);
> > > 
> > > OK, this makes some sense from the API point of view. When we have
> > > discussed that at LSFMM I was contemplating about something like that
> > > except the fd would be a VMA fd rather than the process. We could extend
> > > and reuse /proc/<pid>/map_files interface which doesn't support the
> > > anonymous memory right now. 
> > > 
> > > I am not saying this would be a better interface but I wanted to mention
> > > it here for a further discussion. One slight advantage would be that
> > > you know the exact object that you are operating on because you have a
> > > fd for the VMA and we would have a more straightforward way to reject
> > > operation if the underlying object has changed (e.g. unmapped and reused
> > > for a different mapping).
> > 
> > I agree your point. If I didn't miss something, such kinds of vma level
> > modify notification doesn't work even file mapped vma at this moment.
> > For anonymous vma, I think we could use userfaultfd, pontentially.
> > It would be great if someone want to do with disruptive hints like
> > MADV_DONTNEED.
> > 
> > I'd like to see it further enhancement after landing address range based
> > operation via limiting hints process_madvise supports to non-disruptive
> > only(e.g., MADV_[COOL|COLD]) so that we could catch up the usercase/workload
> > when someone want to extend the API.
> 
> So do you think we want both interfaces (process_madvise and madvisefd)?

What I have in mind is to extend process_madvise later like this

struct pr_madvise_param {
    int size;                       /* the size of this structure */
    union {
    	const struct iovec __user *vec; /* address range array */
	int fd;				/* supported from 6.0 */
    }
}

with introducing new hint Or-able PR_MADV_RANGE_FD, so that process_madvise
can go with fd instead of address range.

