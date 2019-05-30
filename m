Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC450C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 08:02:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62B28218BB
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 08:02:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OhV4bWr6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62B28218BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB9916B000A; Thu, 30 May 2019 04:02:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D43586B0010; Thu, 30 May 2019 04:02:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBD026B026C; Thu, 30 May 2019 04:02:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78DF96B000A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 04:02:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 61so3423215plr.21
        for <linux-mm@kvack.org>; Thu, 30 May 2019 01:02:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CFQTKg8CDDfI/FhGvQPz+vEiE1D+evnZ1GQxMS1sxwg=;
        b=e3OT4Ds2JbeEGAy4C4SjkRJFtuIynWQeRXkXXW16HLzXkGISMe3YMeG6vGkfxfc1iJ
         +nSreVgXF9rJ3HWsoxgk5bTa9eCb3s0ezmo6exdKyHs5nN6L9ESAglc60cezbeYPKqyy
         tVz6qRimIYkTpXs0QCtWtSRjTr7yfVWAonbC6YuRgn9H1XPiGMB2kf4NhwNzeWsFMPHK
         c4gtOZ9H6cfXMbPUCL8waFuqLL14AsT3aS2LzFTfOz9n9KadDzBDYqMjV3ljeZ/7G+vS
         v42NxM/wwVgDkciEgkqktBMHCz4txyIMnHRGtFUkua6Qkw87peRaefw1sPNgCa1jXI4e
         xg8A==
X-Gm-Message-State: APjAAAWnKUeQJIv/gj5BMK4FqB5xwnX0I1Vsb17NYtb8CS9j3AeqWCUv
	wReMuYRwoOL63rDbdARczW5pruSVwlfp5Im1dVboUiIlbKfJKyly/VyvgBnEY14X2N2Eie88Cly
	IElDU+h230P3qqK4RPnvvpfLflcLj9/RGZLaYnIp918rlJAPIDq04BIImzkwT7CE=
X-Received: by 2002:a17:90a:f48f:: with SMTP id bx15mr2270916pjb.85.1559203343069;
        Thu, 30 May 2019 01:02:23 -0700 (PDT)
X-Received: by 2002:a17:90a:f48f:: with SMTP id bx15mr2270843pjb.85.1559203341861;
        Thu, 30 May 2019 01:02:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559203341; cv=none;
        d=google.com; s=arc-20160816;
        b=bcbRQQruyMB5KyGNRJw0gv2dzoAEqviAxn5GQM/yWgkCVMueHtkyEPlpY+m6gsnXW4
         AvOb7v6+98SKG6/McYpVHIugsz2G8OD/QuD+njykU1BDMll+1yOBG9VWN22OGoKj7IAY
         jr4NkrQxY/q9tq2a9IgOjvd9xWTG85C7foBaTHxT8W6Yjnow2DI+jU7XFV7At5IkEszj
         lrA2Kn+3IXdfr2nnsIjio85zKk/RFyMuuoj2O+bRwQDJexyibWj53qN8PWLf7SL9vfSx
         mvLcsI7B2nCfgXnzowKV9uwyER+arCsbRl+2MAn9QP6s+zk/Nzh+vfYkIx3NTSkQ9UVK
         t+AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=CFQTKg8CDDfI/FhGvQPz+vEiE1D+evnZ1GQxMS1sxwg=;
        b=JhVrnJTMbkYVZYyicKj3sUBLmt8ZK6LXWreURDpDj3WIzbfnX4JG7GLey2KPTPYuQ+
         XRc2P9qT1ywS0MgmyuCwPwcn4boca3/jI5RyLmidpOgRpj2dYc9msQHMnxTSpm+FLtoc
         ER/0vNBbjR1rK7E0n7VPBcqtQ3K8xoWNusXnBww1GXnqMzpLeA1bKD1u5OQCt0bC9oF4
         WYvFC7DslmFicx6fBsgpqAQMoazDG6anXjwAZAiFxYL/rrb8DClfPbfkM7WbfX5PT38l
         YFn5y7sNA/CKh8MXefZPwThwdlWusrlD4I1JLy5bDEWiozf7sgC+PLqKn/szWfCLB453
         nqcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OhV4bWr6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j63sor507198pfb.14.2019.05.30.01.02.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 01:02:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OhV4bWr6;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CFQTKg8CDDfI/FhGvQPz+vEiE1D+evnZ1GQxMS1sxwg=;
        b=OhV4bWr6jwLHmWA2KEv810R9q47LC0F5eMpBsTsEJIPX2mKNA/VDNqgYs0HuQ/vRPO
         SLhJkycoKeU8NKfwp4Sps4m7+Vppzct2bCVzw+CoBpoua7NENTIPB4T5QUyTMdNEmmSA
         fXuQd9XRLjEMrQYtOp82jF+KIXjE0v+AxcjKFyO/0cyqq9P2QBIf1sbenqa3hDnfmQNi
         84z5Xl6NLbUdETg5C+2BGfSeVGZ1+ZmNfNXY1XfWoAVzrQsg/N9B8R3R5xKL/muBqnze
         AeC/Z/X9jjEv33F2kDiRvOFl7/BEorbcTbKvgTXqxRdCVqhRTc/ZhRgpjTRb2T9lNhfM
         Q+hA==
X-Google-Smtp-Source: APXvYqwTgUPIsdDcN/AeO+PQKUbtJnP7GgSqg/Op4jLgAFD5UgIJo1BB/5ybC4rlg2UmXx+oje3UUg==
X-Received: by 2002:a63:9d09:: with SMTP id i9mr2467484pgd.195.1559203341379;
        Thu, 30 May 2019 01:02:21 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z4sm1903781pfa.142.2019.05.30.01.02.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 30 May 2019 01:02:20 -0700 (PDT)
Date: Thu, 30 May 2019 17:02:14 +0900
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
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190530080214.GA159502@google.com>
References: <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
 <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
 <20190529103352.GD18589@dhcp22.suse.cz>
 <20190530021748.GE229459@google.com>
 <20190530065755.GD6703@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530065755.GD6703@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 08:57:55AM +0200, Michal Hocko wrote:
> On Thu 30-05-19 11:17:48, Minchan Kim wrote:
> > On Wed, May 29, 2019 at 12:33:52PM +0200, Michal Hocko wrote:
> > > On Wed 29-05-19 03:08:32, Daniel Colascione wrote:
> > > > On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > >
> > > > > On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > > > > > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > > > > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > > > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > > > > > [Cc linux-api]
> > > > > > > > > >
> > > > > > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > > > > > so user should call the syscall several times to give hints to
> > > > > > > > > > > multiple address range.
> > > > > > > > > >
> > > > > > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > > > > > >
> > > > > > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > > > > > with number in the description at respin.
> > > > > > > >
> > > > > > > > Does this really have to be a fast operation? I would expect the monitor
> > > > > > > > is by no means a fast path. The system call overhead is not what it used
> > > > > > > > to be, sigh, but still for something that is not a hot path it should be
> > > > > > > > tolerable, especially when the whole operation is quite expensive on its
> > > > > > > > own (wrt. the syscall entry/exit).
> > > > > > >
> > > > > > > What's different with process_vm_[readv|writev] and vmsplice?
> > > > > > > If the range needed to be covered is a lot, vector operation makes senese
> > > > > > > to me.
> > > > > >
> > > > > > I am not saying that the vector API is wrong. All I am trying to say is
> > > > > > that the benefit is not really clear so far. If you want to push it
> > > > > > through then you should better get some supporting data.
> > > > >
> > > > > I measured 1000 madvise syscall vs. a vector range syscall with 1000
> > > > > ranges on ARM64 mordern device. Even though I saw 15% improvement but
> > > > > absoluate gain is just 1ms so I don't think it's worth to support.
> > > > > I will drop vector support at next revision.
> > > > 
> > > > Please do keep the vector support. Absolute timing is misleading,
> > > > since in a tight loop, you're not going to contend on mmap_sem. We've
> > > > seen tons of improvements in things like camera start come from
> > > > coalescing mprotect calls, with the gains coming from taking and
> > > > releasing various locks a lot less often and bouncing around less on
> > > > the contended lock paths. Raw throughput doesn't tell the whole story,
> > > > especially on mobile.
> > > 
> > > This will always be a double edge sword. Taking a lock for longer can
> > > improve a throughput of a single call but it would make a latency for
> > > anybody contending on the lock much worse.
> > > 
> > > Besides that, please do not overcomplicate the thing from the early
> > > beginning please. Let's start with a simple and well defined remote
> > > madvise alternative first and build a vector API on top with some
> > > numbers based on _real_ workloads.
> > 
> > First time, I didn't think about atomicity about address range race
> > because MADV_COLD/PAGEOUT is not critical for the race.
> > However you raised the atomicity issue because people would extend
> > hints to destructive ones easily. I agree with that and that's why
> > we discussed how to guarantee the race and Daniel comes up with good idea.
> 
> Just for the clarification, I didn't really mean atomicity but rather a
> _consistency_ (essentially time to check to time to use consistency).

What do you mean by *consistency*? Could you elaborate it more?

>  
> >   - vma configuration seq number via process_getinfo(2).
> > 
> > We discussed the race issue without _read_ workloads/requests because
> > it's common sense that people might extend the syscall later.
> > 
> > Here is same. For current workload, we don't need to support vector
> > for perfomance point of view based on my experiment. However, it's
> > rather limited experiment. Some configuration might have 10000+ vmas
> > or really slow CPU. 
> > 
> > Furthermore, I want to have vector support due to atomicity issue
> > if it's really the one we should consider.
> > With vector support of the API and vma configuration sequence number
> > from Daniel, we could support address ranges operations's atomicity.
> 
> I am not sure what do you mean here. Perform all ranges atomicaly wrt.
> other address space modifications? If yes I am not sure we want that

Yub, I think it's *necessary* if we want to support destructive hints
via process_madvise.

> semantic because it can cause really long stalls for other operations

It could be or it couldn't be.

For example, if we could multiplex several syscalls which we should
enumerate all of page table lookup, it could be more effective rather
than doing each page table on each syscall.

> but that is a discussion on its own and I would rather focus on a simple
> interface first.

It seems it's time to send RFCv2 since we discussed a lot although we
don't have clear conclution yet. But still want to understand what you
meant _consistency_.

Thanks for the review, Michal! It's very helpful.

> 
> > However, since we don't introduce vector at this moment, we need to
> > introduce *another syscall* later to be able to handle multile ranges
> > all at once atomically if it's okay.
> 
> Agreed.
> 
> > Other thought:
> > Maybe we could extend address range batch syscall covers other MM
> > syscall like mmap/munmap/madvise/mprotect and so on because there
> > are multiple users that would benefit from this general batching
> > mechanism.
> 
> Again a discussion on its own ;)
> 
> -- 
> Michal Hocko
> SUSE Labs

