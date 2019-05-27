Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3D1AC28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A6D22075B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:49:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dcaj37bC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A6D22075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29D996B026D; Mon, 27 May 2019 03:49:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24DC16B026E; Mon, 27 May 2019 03:49:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D126B026F; Mon, 27 May 2019 03:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF9056B026D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:49:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so11265234pgo.14
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:49:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UAaLUDeqiG1NP6oRWwwXznCvAzla34GzLiXiS6KmTYY=;
        b=KsX8H3gOZ5dwu81pRS8TYDtIbGYg28XIQ+8oAk5K+YOCYJAnoybci/eAgdTnJFp2hK
         h6R8IY1U753Z9Om0Zg9WDF/vZvVBurg3IQC8w7ZZ2IvMYKkKh+3m4fQ0kZvIhWcUGpW5
         tBPsnAmxrN4rSMnKgAI1sCrOCI5vuLeavkEbDpfzwGdBfff4ceSgOWXqE1Xuv6msuS2P
         9WCIKPWZDwt3ZYB0241Jf4Uca66D8VjAsVNy4FVaDETGHv935hACQQQje1Brq+P4NWhH
         i8by0ScRycUV+IqHPA0yWC4MOdjCB3btQWoQ9x7+s3P3bKkxBkNqYt9KdWOo5hX4sO+s
         6KvA==
X-Gm-Message-State: APjAAAUWRmcae5JCdbdpzTP8YgiZX1h7AfOfeyTS48w6sdDizDK6wGZj
	LgnH5+2ZrNoDUQQZ9CBn7Zp+HN7m6l1eJ9aauNb71KMq0eblsqPQxVSg/mt34Kg4ZqNrK243BYf
	7QIwdiR1z0sovxUq3+wZR2SQ30BYsQ9yZ0WV2lSbyDPZVbyxvyE6aLt0MfpXxkJg=
X-Received: by 2002:a63:fc08:: with SMTP id j8mr123081586pgi.432.1558943388436;
        Mon, 27 May 2019 00:49:48 -0700 (PDT)
X-Received: by 2002:a63:fc08:: with SMTP id j8mr123081513pgi.432.1558943387513;
        Mon, 27 May 2019 00:49:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558943387; cv=none;
        d=google.com; s=arc-20160816;
        b=d5+uv4hJondQzoEy2UmSys9yuH1KxEtX5pUsqwCvG+JH/PmiDL4n0+d8KxMROgcDiz
         pk2t0bzjYOT1U6hfOUe0racj+N03FL/EpEO2cZ86HDrikoBn29KP6HQd7LNKA15IqIBu
         0WtHCvUfASiekG31DwrJU646rz3N82wUdViJrKId6eCylCDRjrA9+c4IyqF91UGxoUec
         /PsWLEXLnCZ0x75TYiQGBAmLf5SLrJ+T9YJD7/9DKdQ9yLFlrzUQ9pwF2bVHU1dJITZM
         YpCaFFTEYjF+GyRfM+GvY0t7qUHiFOLZrUI5axFoQF7j5w6e3JtpPUG+lCTQXANgNq86
         qzHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=UAaLUDeqiG1NP6oRWwwXznCvAzla34GzLiXiS6KmTYY=;
        b=HXZAhroJ5L6JCsIrPQ3L1BG+79IdwCXRpXIqFyk+02+iwiNkoXQt8RHsslfGWaEQTN
         qw9z8eDA6OPQ3/Da09i4XbzGEH/Zdum/ohnFlZt6pYNFZ8FpqS/eMCu4O3VMqzy5B6YB
         C25HTBhWnsDBBJeMXfgxR4K1LxnhFNVVbgSF3r0S+CudHGnerN08PAEOJfrrCeYIeIUV
         I4sbinAQhfOGwflmLveLZun4J+3ilbsETlqqlqhQExE4y8E4nJGNelwBvN7ZF52s9Sz0
         YSx4MlJRM5vV7BZ57sWJUxT8GGP3wWCfjRrmxcPkSejWpVg0LsIoOxNFNDBIBCcsUm3q
         YuRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dcaj37bC;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bh4sor12558882plb.25.2019.05.27.00.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 00:49:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dcaj37bC;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UAaLUDeqiG1NP6oRWwwXznCvAzla34GzLiXiS6KmTYY=;
        b=dcaj37bCGUBkTgKtlwvXFPEIuX2F6UmuMUU5vrFtZ3MCfY5mEozm2J0Kxt0xiWbjBx
         p5j/krk+oCCMX1wl7lfkOqs2PJiP+4y2Z+jHyS0+VH4lZyT8b+FbwGyjtxfgsgGgiw2n
         bqMXvJcr5CFZM6QbRYbqqY/0oHmhio8Ky1QfKX7vrgL8O/9ZqYFYACTfyFVYnnsrZQXz
         TnVe+KKgKAUnZERuRC4nlyRiVrVCrror364HWIUX+r5ew7kKXg/j+cepsCNa/GZpqq2r
         hpVaPnIJdna7Ev8sKDaKYlw9eZsUkuUvf8AeN+KaKWaDR4v4cvYgJZP4OkNhyBsv0E2T
         eo3A==
X-Google-Smtp-Source: APXvYqysI7IOkBNmcR/djcrJ/5JIth+TrYyPAhn/ojlSa+KZOHOuhmEpThUW7Eam0JapW4Wf5PUOuw==
X-Received: by 2002:a17:902:2e81:: with SMTP id r1mr110527179plb.0.1558943386837;
        Mon, 27 May 2019 00:49:46 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id k190sm146239pgk.28.2019.05.27.00.49.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 00:49:45 -0700 (PDT)
Date: Mon, 27 May 2019 16:49:40 +0900
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
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190527074940.GB6879@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521103726.GM32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > [Cc linux-api]
> > > > > 
> > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > so user should call the syscall several times to give hints to
> > > > > > multiple address range.
> > > > > 
> > > > > Is that a problem? How big of a problem? Any numbers?
> > > > 
> > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > with number in the description at respin.
> > > 
> > > Does this really have to be a fast operation? I would expect the monitor
> > > is by no means a fast path. The system call overhead is not what it used
> > > to be, sigh, but still for something that is not a hot path it should be
> > > tolerable, especially when the whole operation is quite expensive on its
> > > own (wrt. the syscall entry/exit).
> > 
> > What's different with process_vm_[readv|writev] and vmsplice?
> > If the range needed to be covered is a lot, vector operation makes senese
> > to me.
> 
> I am not saying that the vector API is wrong. All I am trying to say is
> that the benefit is not really clear so far. If you want to push it
> through then you should better get some supporting data.

I measured 1000 madvise syscall vs. a vector range syscall with 1000
ranges on ARM64 mordern device. Even though I saw 15% improvement but
absoluate gain is just 1ms so I don't think it's worth to support.
I will drop vector support at next revision.

Thanks for the review, Michal!

