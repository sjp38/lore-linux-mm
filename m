Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18DB5C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 02:17:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75292442B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 02:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U0XfxOsc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75292442B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FA766B0010; Wed, 29 May 2019 22:17:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A87D6B026D; Wed, 29 May 2019 22:17:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 370B96B026E; Wed, 29 May 2019 22:17:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F255F6B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 22:17:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so1292857pga.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 19:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=J+LGGnWuJWHM+WKg8MeU6gQViXIAZaAk3p0BItg7HfQ=;
        b=Oqc3sFpijoESbvEc0OyYOdWQs87cpgX+10WizQUjKilmr2PBzGrMTRsHfT0CSrDXgS
         ey9ZVdxF6HWefxgjtkeu907tH9D59UxgKgqaAOqXif9iibV5rYjDf44+Jye7wtgAwtLo
         D7+n2TEagB3/bByx3ard+zw0IwVsRTxvLER4dDh1nl1FZIjWNk2uC29uXdcF+/dHAv6L
         aBAI8pZj+6dF2vOhXcFjKAGH/zhzm3LQxdP36yOzQM6mtZRu+MmPtGCc0DXumMj3Rfr2
         1RtFEBJoqtJn3b347EpV3EWKaKKYxOx0WQwuxtkgXPqIQZIctsv/Hs4P2MZUYmHhHJTU
         9edQ==
X-Gm-Message-State: APjAAAX+t9aVDX+wO5WsxaSTPSfbTWPqoBIUycqPRfITFxhZBpGM32tJ
	jShesicsss91mT/5lBh7G8hQX92ObRxZEo493k0x+vqIygltdF7hVvPoaDwPvHUJwN0R3TWM3zq
	OMVEQKT15Y9fXmtzJsT6HggiTFXOnuVSP5kMBzT5imkas7zxlCu/hfhJJwYadH0U=
X-Received: by 2002:a62:4d03:: with SMTP id a3mr1145626pfb.2.1559182677561;
        Wed, 29 May 2019 19:17:57 -0700 (PDT)
X-Received: by 2002:a62:4d03:: with SMTP id a3mr1145525pfb.2.1559182676377;
        Wed, 29 May 2019 19:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559182676; cv=none;
        d=google.com; s=arc-20160816;
        b=0NexhMxxUUF3wks4zXg0GyDOCM8yJ99GV/5MRglFDOXsvVQaTQyPpHRsRqU0cUi90L
         c5jkXjsxGfdScyr/vMLoK0w5X1ablWC7/4Uj/cke5KNszFvw/4JvOb1wcv3AB4qs0V8z
         GP5YQ0wU9TpSYRekZnFuvy0dXk5wXkiOCk3IaZLjnZrMBa5oBoxIuhW7k4oKqARj3bx9
         xpwwEumF1c9G42ZXP5Hv9WWGbN5egumTq/xPkEOHtgpzt9m0GYFiswVpeDa3IsfSvRxo
         gwMnmIWLVjz09IDcMSQx4LO2xMkNWmm/QcyTvZ0udLA4Fr+MAV2jLOZGxQEBvI1XSGvN
         ApJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=J+LGGnWuJWHM+WKg8MeU6gQViXIAZaAk3p0BItg7HfQ=;
        b=TLiu3LiTvXi/0NpPCmpuNJW4HORU7pCfWgrQMdAeNSracI4v5YbMGNALjnzZhBlHR7
         Kfw3rmaATVmWQFnHgdD+3Ym1W71GTktUdt3KlcH4Wo8JORNKW5X5S4qeq9dFpMjYlz4E
         KIYscJsCKVpr5K3UiYYVrEmtGt3slf96jKuxANaB0yknlnChA9yJDHn6XShQIGvyPWnp
         jiuNt+Jd5/dBF89YAXPlP0GDhfJupje+TiHyLSzhzHRR3mtrwUadSDVtVXtfGRs4h4nJ
         inPJ4WDpkpB45EW6Pp+dwB5LNO7bPbjbl6rjBY7rcrMM4X7Ig20luRFJHGjtmf+Pa9PC
         s8Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U0XfxOsc;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor1657756pff.2.2019.05.29.19.17.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 19:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U0XfxOsc;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=J+LGGnWuJWHM+WKg8MeU6gQViXIAZaAk3p0BItg7HfQ=;
        b=U0XfxOsc2OjdQNPm9YJSBLzCkPPka1w7KrIp8pfB9nSjkHD3XrqaanRyTU6Ibf3sOE
         uPc44k60qghDz6uZY3QXZFyl4ZIdUkKfVqVPfvnXvKzgCNTTP0Kg4L53SkfciBTy24PH
         M131ULqW0TNdVD9v46mTV8F/ORYDQINPwHKDV8+tAVVwDDNv4gAiJBUqdYG/jteTLvh0
         jnWDDl8ybAsf24TeIa2DUdXqlFCinU0eIORRz9zMVhxurVEHbLgtEiRyMpP1/GHFNz6W
         DGBOxh54730ahlQmCWu3i+iHBd7RSujz8NQZGycKXA/twSos5CRjIcz08kZvsaRAp9J0
         p+zg==
X-Google-Smtp-Source: APXvYqz99GsR3E/xgrKz139jKb0mewXMFlMkRWz23qGbtOHzhcmYVGdIzRT2lqrEuBCIIuj/OVhYqw==
X-Received: by 2002:aa7:8a11:: with SMTP id m17mr1117999pfa.122.1559182675823;
        Wed, 29 May 2019 19:17:55 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x18sm1054452pfo.8.2019.05.29.19.17.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 19:17:54 -0700 (PDT)
Date: Thu, 30 May 2019 11:17:48 +0900
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
Message-ID: <20190530021748.GE229459@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
 <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz>
 <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
 <20190529103352.GD18589@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529103352.GD18589@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 12:33:52PM +0200, Michal Hocko wrote:
> On Wed 29-05-19 03:08:32, Daniel Colascione wrote:
> > On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
> > >
> > > On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > > > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > > > [Cc linux-api]
> > > > > > > >
> > > > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > > > so user should call the syscall several times to give hints to
> > > > > > > > > multiple address range.
> > > > > > > >
> > > > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > > > >
> > > > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > > > with number in the description at respin.
> > > > > >
> > > > > > Does this really have to be a fast operation? I would expect the monitor
> > > > > > is by no means a fast path. The system call overhead is not what it used
> > > > > > to be, sigh, but still for something that is not a hot path it should be
> > > > > > tolerable, especially when the whole operation is quite expensive on its
> > > > > > own (wrt. the syscall entry/exit).
> > > > >
> > > > > What's different with process_vm_[readv|writev] and vmsplice?
> > > > > If the range needed to be covered is a lot, vector operation makes senese
> > > > > to me.
> > > >
> > > > I am not saying that the vector API is wrong. All I am trying to say is
> > > > that the benefit is not really clear so far. If you want to push it
> > > > through then you should better get some supporting data.
> > >
> > > I measured 1000 madvise syscall vs. a vector range syscall with 1000
> > > ranges on ARM64 mordern device. Even though I saw 15% improvement but
> > > absoluate gain is just 1ms so I don't think it's worth to support.
> > > I will drop vector support at next revision.
> > 
> > Please do keep the vector support. Absolute timing is misleading,
> > since in a tight loop, you're not going to contend on mmap_sem. We've
> > seen tons of improvements in things like camera start come from
> > coalescing mprotect calls, with the gains coming from taking and
> > releasing various locks a lot less often and bouncing around less on
> > the contended lock paths. Raw throughput doesn't tell the whole story,
> > especially on mobile.
> 
> This will always be a double edge sword. Taking a lock for longer can
> improve a throughput of a single call but it would make a latency for
> anybody contending on the lock much worse.
> 
> Besides that, please do not overcomplicate the thing from the early
> beginning please. Let's start with a simple and well defined remote
> madvise alternative first and build a vector API on top with some
> numbers based on _real_ workloads.

First time, I didn't think about atomicity about address range race
because MADV_COLD/PAGEOUT is not critical for the race.
However you raised the atomicity issue because people would extend
hints to destructive ones easily. I agree with that and that's why
we discussed how to guarantee the race and Daniel comes up with good idea.

  - vma configuration seq number via process_getinfo(2).

We discussed the race issue without _read_ workloads/requests because
it's common sense that people might extend the syscall later.

Here is same. For current workload, we don't need to support vector
for perfomance point of view based on my experiment. However, it's
rather limited experiment. Some configuration might have 10000+ vmas
or really slow CPU. 

Furthermore, I want to have vector support due to atomicity issue
if it's really the one we should consider.
With vector support of the API and vma configuration sequence number
from Daniel, we could support address ranges operations's atomicity.
However, since we don't introduce vector at this moment, we need to
introduce *another syscall* later to be able to handle multile ranges
all at once atomically if it's okay.

Other thought:
Maybe we could extend address range batch syscall covers other MM
syscall like mmap/munmap/madvise/mprotect and so on because there
are multiple users that would benefit from this general batching
mechanism.

