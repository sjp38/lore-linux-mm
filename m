Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 738F4C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AC842075C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fvqIxpSu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AC842075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA7146B0273; Tue, 28 May 2019 06:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B585E6B0274; Tue, 28 May 2019 06:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1FCA6B0275; Tue, 28 May 2019 06:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B34F6B0273
	for <linux-mm@kvack.org>; Tue, 28 May 2019 06:33:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so7238419pla.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 03:33:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=krgMSnEVy69yoxUL6+FT3pw/Wcuo2yl9vll0sSUGOww=;
        b=Ri0yR4TCc3JAdtKLoGgtU1F4zZh358X5esw3c0Mex0324k/9Av0K6PUq8Frc6QpaOD
         zI6NvGHGaK/T3UMlJk0VfuZn/+hpTvpJ4ZN4YedWDUm8Cft/nhpcT1rn3W4DWJx1+72p
         VSNcLJK0ZK1RnfbJm9Rw1vCltG7UVACtCHQGKVvZkLni5No1vmx1a9xOzWMczIVJVXsa
         14/0pwhz4rGIzF4nsm0j5iXo++pYznK2GHloDC7jw2nmAuIFuAiIvTQGRx4lFcXf5ZE/
         Fxr4GqRQcUJua0A/+IUwQTWLXVAKJfJPiwPsKoE6b1KisS5aa6Jk+Adg1/THooNqJEuS
         u1Og==
X-Gm-Message-State: APjAAAXrsUgT2SsUG5JaSUENYqjvRQoPqYpAz9tmQNysfUxT2gHvAns/
	4HudsWjTIcVt/K5f6BWI+kPrz8O56m5ooOP0QsbjCWZ4ebZ2dzzOCjY7KTrB+YmUMziN+ssaxQ6
	fwcISuumH5YZQtw3Mp7QxldGjYFW+NnB6gc477kV5MnUxSPpUegpYF0ysDLYHVqc=
X-Received: by 2002:a17:90a:2302:: with SMTP id f2mr4816820pje.124.1559039584931;
        Tue, 28 May 2019 03:33:04 -0700 (PDT)
X-Received: by 2002:a17:90a:2302:: with SMTP id f2mr4816700pje.124.1559039584106;
        Tue, 28 May 2019 03:33:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559039584; cv=none;
        d=google.com; s=arc-20160816;
        b=uL3Q5QrpF3ZBB9mRsfzsUSnF946DGFrwnaixy97BQOg7w0XKT/CUtrDbGU57ws2XU0
         7RdK+MuEeoV9RiK4G27/z1b//5kgoOBG+SXxaATq0y9aF/zq3MRNLzwLcy3C4RNy4GVb
         CiyUR6K53n8KjabHoDjVVIW86ea1qRsPaH1VjP/nZ/wWQhIqglN6DeVTam2lfCR7to3f
         pIYgb7d511cOjgT2hbpc/CsuM0bKWckWutmkq6NWP1fBCkFVwXGYIKLmrzM3cOppfZBy
         gSfG+++sBCpMhIl07Z4lc/Q+SSQaIdsw8rOPyenPcFFp2Bz6AuZQkmcLSfw04fC6pj/8
         8Acg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=krgMSnEVy69yoxUL6+FT3pw/Wcuo2yl9vll0sSUGOww=;
        b=bR5pwbPPGQtWTf5hw0vgPO6pa35HRgK2Akkijtok5XyLPWwYBgQ9Qq70aYLdbioJ/G
         tl+/nTwe+MFuYUuxHI2BvKT9P4IMPG4kR1i2mPzysBPmXQQO2Z/xJqSXpE1afexVqtjW
         ICbW34HG+SFLwwZT4A3JOLehaK1yIy2+e0HRvb06IscKtWc16+N5Q3poJt3kJ779pFIQ
         AxKQb/fmiup8szSMts3A2Da//pyhUDGNspGBGz6UksOesUKvlHLkqk/vFcFP/0xlLx2z
         HPmqkKOlImSbV9K+iGotdW3ilTAfJVoBYLTeR7dYzjJ73Zt5P8tOvYdDMeGOOcBsshtc
         wl4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fvqIxpSu;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o12sor16134466pfh.39.2019.05.28.03.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 03:33:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fvqIxpSu;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=krgMSnEVy69yoxUL6+FT3pw/Wcuo2yl9vll0sSUGOww=;
        b=fvqIxpSuquyR4BpSeT5rFWP7ErwjkwJUnGWEyfvDGxz5/uVzNBZyAiZUKtfnK9WSVm
         H92bdTd0JQq+meoxC/A7cAvM+LRpEpouDQA/Ac2uSJKJPNOzcy4CzGpjewrZGPEG8LHo
         QASLekxEG4UQqoj3JFCRy87xxphDAuDtN6Oti3uuco3K8+nygGPwAroVtyo+eM4hURtU
         7CKlX+ZoGV4ttxIBpBpa2Bh1pNKOMsk2eIWVef+vUVuyz6yF4SY+KQkJXIyCcdZc0eFm
         hCLhXnKVp4N6ZqzWkdxWMrxBHfFRe0MCOaSf3xL6YVgnU31InTxQImkkGN5E4ypIlJXY
         YTGg==
X-Google-Smtp-Source: APXvYqxc+D0LEa1va91F68TbeYEmhMPMKJQZ9LgkOR5KNw+jdrb9GAAsS0CDZJbmp0XQkrYEFbL5rA==
X-Received: by 2002:a62:2c17:: with SMTP id s23mr112033131pfs.51.1559039583555;
        Tue, 28 May 2019 03:33:03 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id m7sm8226184pff.44.2019.05.28.03.32.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 03:33:02 -0700 (PDT)
Date: Tue, 28 May 2019 19:32:56 +0900
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
Message-ID: <20190528103256.GA9199@google.com>
References: <20190521025533.GH10039@google.com>
 <20190521062628.GE32329@dhcp22.suse.cz>
 <20190527075811.GC6879@google.com>
 <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528090821.GU1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > if we went with the per vma fd approach then you would get this
> > > > > feature automatically because map_files would refer to file backed
> > > > > mappings while map_anon could refer only to anonymous mappings.
> > > >
> > > > The reason to add such filter option is to avoid the parsing overhead
> > > > so map_anon wouldn't be helpful.
> > > 
> > > Without chiming on whether the filter option is a good idea, I'd like
> > > to suggest that providing an efficient binary interfaces for pulling
> > > memory map information out of processes.  Some single-system-call
> > > method for retrieving a binary snapshot of a process's address space
> > > complete with attributes (selectable, like statx?) for each VMA would
> > > reduce complexity and increase performance in a variety of areas,
> > > e.g., Android memory map debugging commands.
> > 
> > I agree it's the best we can get *generally*.
> > Michal, any opinion?
> 
> I am not really sure this is directly related. I think the primary
> question that we have to sort out first is whether we want to have
> the remote madvise call process or vma fd based. This is an important
> distinction wrt. usability. I have only seen pid vs. pidfd discussions
> so far unfortunately.

With current usecase, it's per-process API with distinguishable anon/file
but thought it could be easily extended later for each address range
operation as userspace getting smarter with more information.

