Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5121DC46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B56A208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:22:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nOfmaveB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B56A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E39F6B027E; Tue, 28 May 2019 08:22:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8933F6B027F; Tue, 28 May 2019 08:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A8906B0281; Tue, 28 May 2019 08:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40DC76B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:22:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d125so12465335pfd.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:22:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AJ8VRsxsoWGs/vBSV1ADUeGhgVxuJp/KwJ0JXgr2QW8=;
        b=crFr11RlqI4QKL3MaG1qhvL7PVsgo6JSz8XylmF5gLQ0mwRtZDasDQwWf19VvLh+qE
         fsHxAPXCQIkxb7Bebv/CG6g8V+yhlb5rPq9dQh/63CfReZf3A9cEWghRroqBJv18ARLm
         MVvs6a8R7NVlLD7B5MtfoLICStOzqYJgo0lTceAeQzVHV22gRpqv+u6JcdIcLbO4FGOk
         ithSRWjYng3Nb4dxNaJIbpfDlPnAqwH6WkQZyRjza2j0F/7o8m57i5cJt91g9XOt1UPz
         7R4/jYsQQKfkGnD/k6qhgM6sAXH8uPWYXx9IWWr5X75URjolhPycDGRnYV350hU9vVns
         NHDw==
X-Gm-Message-State: APjAAAXbQTapcbsj407ciLGm/s1RtmUqRlfzf8vBrf9UkDNzZ2DDPTAA
	BjisGyAxG66PtQOWdec/bSHDoCqOlO+7quAmEmBGnvKG0T6jKGdL5Z5QQejvgcsfqRWU8HAL5S2
	X1gzUE7/rDtsRYz15A6gBpJn8s0v9Le6MFONwSEAjnFTMED+KtwBwPGqzwtKNYi0=
X-Received: by 2002:a17:902:8f8f:: with SMTP id z15mr83233071plo.93.1559046135863;
        Tue, 28 May 2019 05:22:15 -0700 (PDT)
X-Received: by 2002:a17:902:8f8f:: with SMTP id z15mr83232989plo.93.1559046135086;
        Tue, 28 May 2019 05:22:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559046135; cv=none;
        d=google.com; s=arc-20160816;
        b=QIl/4XvjiXADVXYU/8ziJPN3pLLWqNFnwEIhyMHnpiIIH0LEdgmfvbjVCNHSN6NCuf
         PUwuj8BCuerMvGU0MjOG17GBJs9OTUiJSY+ylOc4e/uFZXdNnZp8JXvB8nfBdqtdTt7X
         XAuI5iPKe8uD3CRZj6FLMY4NwmFz3tEU1wHGP7LSEi8OIrH/2JB4dhPJ2/QHWbw4N59B
         rS2GjCPnT42bVpZQVPLRH2QcEGoyox0o+Sr58F+/FkxRHwSg2NMV0bFAuxT4Gt89p6Pe
         cbsPxIWvcWwQmDRkAWcvGn2xZEMvHA4l9uGmdDy8ZH1b74TJay6kREZwHZbEo7OJ/B9c
         w8Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=AJ8VRsxsoWGs/vBSV1ADUeGhgVxuJp/KwJ0JXgr2QW8=;
        b=h1qhMGt5YD+gfZ1T3wW5h1xil4lnuIN3aD3EBbeNashzOUMI6xRBnzDmdOJAMcP+jk
         tvfmdmzOP/PDae5Wy85awz++2wgL6n0CdUB0GCffApFErfsVsIkmOL7X3N6ZAEq/jPHZ
         3YMkbDnB4WAqmUogas9bh5UdH7xE0zgY9VHWNWqcR5e03TfzaM6U7LIz3RM7zWD+OIol
         apro4EFRDl1tKN2T/Z7wmClPvp1EltV+GOxqpXWB7m/wereKMorlVopG7RuZJ8vz0fBw
         SttZ3RJaTWsPaCPh+b8pWRvFVbZmSSsYe6wxjD+xNL9mQxbT5fu+BcjqW4fk7ecuPW+b
         6tgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nOfmaveB;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck13sor17034188plb.38.2019.05.28.05.22.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:22:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nOfmaveB;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AJ8VRsxsoWGs/vBSV1ADUeGhgVxuJp/KwJ0JXgr2QW8=;
        b=nOfmaveBw33qA+XOhBteLcPyL6U0iAwH31DZFkeev74RKVWIws7CENGYDnihRDjxvn
         nCSw3qHhQW9dZsKA3TKHyivcfswE3XdA9LbjIbTloBrbMUu3qCfhcahqTPjJl0c2BHwF
         Ba2JzCTarLEOdUUnVtU94PDddmwZRE2ZSfocpESfyPTDwtaK8r/Oo7dIbyD+lJR2PkZe
         z5yy6U4PyW7okX5RiXlxAYZTR2aoWnaWNfGqD1u7PcQRsptm3U1jVZdg5qnUVZ1mJufG
         ED5ixHOJ4Tos/q69eKg1psE/LcRiqlnlfCoTm84cOZT5jDb6CrabqUYSIp1T62ntfYa1
         mJ1Q==
X-Google-Smtp-Source: APXvYqyxBBA1c7fo0kmqewKRmZb4uXkX32qK6cXRlHYmibj6AYwQWFyVNY2kFpvESFd+P8Oc5wfClw==
X-Received: by 2002:a17:902:8a91:: with SMTP id p17mr70129886plo.60.1559046134645;
        Tue, 28 May 2019 05:22:14 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id o7sm18655494pfp.168.2019.05.28.05.22.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 05:22:13 -0700 (PDT)
Date: Tue, 28 May 2019 21:22:07 +0900
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
Message-ID: <20190528122207.GD30365@google.com>
References: <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
 <20190528114436.GB30365@google.com>
 <20190528120614.GB1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528120614.GB1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 02:06:14PM +0200, Michal Hocko wrote:
> On Tue 28-05-19 20:44:36, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 01:28:40PM +0200, Michal Hocko wrote:
> > > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > > >
> > > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > > > 
> > > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > > e.g., Android memory map debugging commands.
> > > > > > > > 
> > > > > > > > I agree it's the best we can get *generally*.
> > > > > > > > Michal, any opinion?
> > > > > > > 
> > > > > > > I am not really sure this is directly related. I think the primary
> > > > > > > question that we have to sort out first is whether we want to have
> > > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > > so far unfortunately.
> > > > > > 
> > > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > > but thought it could be easily extended later for each address range
> > > > > > operation as userspace getting smarter with more information.
> > > > > 
> > > > > Never design user API based on a single usecase, please. The "easily
> > > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > > several times, the synchronization model has to be thought through
> > > > > carefuly before a remote process address range operation can be
> > > > > implemented.
> > > > 
> > > > I agree with you that we shouldn't design API on single usecase but what
> > > > you are concerning is actually not our usecase because we are resilient
> > > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > > Actually, many hints are already racy in that the upcoming pattern would
> > > > be different with the behavior you thought at the moment.
> > > 
> > > How come they are racy wrt address ranges? You would have to be in
> > > multithreaded environment and then the onus of synchronization is on
> > > threads. That model is quite clear. But we are talking about separate
> > 
> > Think about MADV_FREE. Allocator would think the chunk is worth to mark
> > "freeable" but soon, user of the allocator asked the chunk - ie, it's not
> > freeable any longer once user start to use it.
> 
> That is not a race in the address space, right. The underlying object
> hasn't changed. It has been declared as freeable and since that moment
> nobody can rely on the content because it might have been discarded.
> Or put simply, the content is undefined. It is responsibility of the
> madvise caller to make sure that the object is not in active use while
> it is marking it.
> 
> > My point is that kinds of *hints* are always racy so any synchronization
> > couldn't help a lot. That's why I want to restrict hints process_madvise
> > supports as such kinds of non-destruptive one at next respin.
> 
> I agree that a non-destructive operations are safer against paralel
> modifications because you just get a annoying and unexpected latency at
> worst case. But we should discuss whether this assumption is sufficient
> for further development. I am pretty sure once we open remote madvise
> people will find usecases for destructive operations or even new madvise
> modes we haven't heard of. What then?

I support Daniel's vma seq number approach for the future plan.

