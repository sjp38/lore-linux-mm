Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453D0C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 066A520675
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:39:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NtAmxsdF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 066A520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 923FA8E0004; Wed, 16 Jan 2019 12:39:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D0B78E0002; Wed, 16 Jan 2019 12:39:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799338E0004; Wed, 16 Jan 2019 12:39:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 204F78E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:39:27 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id e192so1578059wmg.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:39:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SkHnhOOsLYZDGsqCGEnCW12gFbGohE4xp9i6QhoRkNQ=;
        b=RDWYHLYpQauIRPmnWs9vczuxDVXv26iR6pjrlSNjN5fKMQURRi0J45hUjGO0pqTqij
         fxhhFi0doTbRfMocs5OlWYVwtJWYYwNHsla1SkjgMJMnwEQu98Lue8EBhkEzn6e3BbX5
         WCLbAgd5GQ+TRAXJbDCgfIUUDkoZ2+phrDvMHziMZk/B9seHAtIY6ytsbswE4Fbbkve9
         0iuBR2DRBdya//pufrQzN7RLScwQPxieqcH5PUgW4I4nWOg45NWoJz3mUvoKxRaiPq9v
         i3Hm0vTmYdhfTygcEHAJOFz3hHrdUf39nX15YIDuPjyaGcGHHi5TUVBk6/1gvu+qn85f
         XTwA==
X-Gm-Message-State: AJcUukd6BaeBBZ793LEcR9rV2c3+nUj6o43oFZyZsx3/LrK6WtdDPLEM
	sPsf27rF0QfHx1kvSjsfOWxLAvO9HQxmjdZjSPSPCKz+S0o2hinshpMqWSBjESp+qhWTIjLuaS/
	F8TXo3UxMOwr12+AHuYWWeCmFUY01T9ei5pEghfrfEwl0eH1c409uhJfitG7CwUMGXDvU0WehIk
	H0nxssbLmJYeIdi8aVXoV9qiV/1UBC6cEygcNFe1zMvjiSMjH74PysSSE38FG9gN7AFDWI8f4XP
	o52z3XREAD5H580W9nnVfI1TjykhZT1BRX6PaXMBpmBovtrH1Hy7ctpG0l0Kkc97I+OV0SpDgSA
	aZt1U8vzpMMk1KdjPE2Zh90E3lGx42fdng+aeNy3MUsmwlLZaMg5Im95b6i4Bfo/PpbJVlrLUDR
	g
X-Received: by 2002:a7b:c44d:: with SMTP id l13mr8547251wmi.144.1547660366678;
        Wed, 16 Jan 2019 09:39:26 -0800 (PST)
X-Received: by 2002:a7b:c44d:: with SMTP id l13mr8547198wmi.144.1547660365727;
        Wed, 16 Jan 2019 09:39:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547660365; cv=none;
        d=google.com; s=arc-20160816;
        b=hXWQ4fXqrKEf9YqpCvYuui1nNVUkYNDxym9iV2l1AIIcpbPm/REp9COy1Qyihj933X
         QqSOw9vfawbvNHPI1UDFSFewwqSuFIuj6ntnVyfqQfghvb9jqKCbjrIQGs8CKv4Z0TOL
         Fxsk64APMbNeIAATqjqlLh2zAx0WAYK0TDj0/hyMIfeHXRRIKk+pvAx0G7StCtTCdWjA
         pJdaRbAIGfVV/mn3BLBPj7wIn2tLwfSnWnn1QZmM74zstiOTUox10KajTSuGGfEmbwpV
         p6+YGFR1rTnta/PPDpams28sOYUe3oMzrItY5x9nVVmtjp+tI7cBcQMvHuN1EC4brLF5
         nGNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SkHnhOOsLYZDGsqCGEnCW12gFbGohE4xp9i6QhoRkNQ=;
        b=g5JAHKVA2vx59l7kLDJkYcfo/5PG4czpRgW5fGdUr+5IC+ThOhM15i+f7uMVBDNxsU
         bxFHAFLUpEAmnucjG74kIWr05X2FrVryQdC3EkOq071/JAgMa2qICFWcdZ4m/SjvIuMP
         sIGeJDf3AlWN4MxYpNdgpN9BftcfKcIELXBL1u3GeHf6O2KN8n7H5IgvVHoIFjnuM37K
         Ji5X/ZcFxvnoupmtgjcnWOQfNs+61ddxWvzu6P6CizUzVxWlDOJ1YMBahAF4jQapIkpE
         qb16xx38NSFxyw+Dohqu2mUFrArCJ2RGPmJ3i5oWnxr66N8zNdx4v8mJpGsqKprRhWl8
         Mu+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NtAmxsdF;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y140sor23373356wmd.12.2019.01.16.09.39.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 09:39:25 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NtAmxsdF;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SkHnhOOsLYZDGsqCGEnCW12gFbGohE4xp9i6QhoRkNQ=;
        b=NtAmxsdF4VzGKlpT0lmtbvYJiLYQMDar/xlqxYhw6D/UuTkJBzDMdyd/hiLxRfJO2Y
         284bfW00aWxNO3W84K1wxGC6FdOVJi3yht8vSyaV9LVwNt1yWJnscmHq3scQVZtP4Yuk
         NwdR8JXXdSFdSAmlvuSToZrQ/1bb8/noYvzuqfdtVX0xUUnPV6bQrcw9L3LKLovGVP+a
         uzrTmr2uyUgJHhZg3HRVoqkKn3znCcQjf4OTkB+imsQXGBrkBA+FnOyjvMOOQYf8jqSX
         D9JFbu4kXY2Fw56nyWXDxhFO9QXWJjEvtIXpBlx30XSDmtk+M8rtFEcrG+bEWE3SSi5R
         hSuw==
X-Google-Smtp-Source: ALg8bN6oK6ZMXC6QP6glapW5Kz8wmrchdwcnXsZIFNdiaWklrjvQy5e6RMf54NWRKDfot/WDFnQ5niSjQUdpmd9n5oE=
X-Received: by 2002:a7b:c951:: with SMTP id i17mr8931903wml.70.1547660365119;
 Wed, 16 Jan 2019 09:39:25 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com> <20190116132446.GF10803@hirez.programming.kicks-ass.net>
In-Reply-To: <20190116132446.GF10803@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 16 Jan 2019 09:39:13 -0800
Message-ID:
 <CAJuCfpEJW6Uq4GSGEGLKOM4K7ySHUeTGrSUGM1+EJSQ16d8SJg@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, 
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
Message-ID: <20190116173913.jU7DNkmKwBteh3uO23c464k0iMSyt7zygN9jEKCZkk0@z>

On Wed, Jan 16, 2019 at 5:24 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> > For memory ordering (which Johannes also pointed out) the critical point is:
> >
> > times[cpu] += delta           | if g->polling:
> > smp_wmb()                     |   g->polling = polling = 0
> > cmpxchg(g->polling, 0, 1)     |   smp_rmb()
> >                               |   delta = times[*] (through goto SLOWPATH)
> >
> > So that hotpath writes to times[] then g->polling and slowpath reads
> > g->polling then times[]. cmpxchg() implies a full barrier, so we can
> > drop smp_wmb(). Something like this:
> >
> > times[cpu] += delta           | if g->polling:
> > cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
> >                               |   smp_rmb()
> >                               |   delta = times[*] (through goto SLOWPATH)
> >
> > Would that address your concern about ordering?
>
> cmpxchg() implies smp_mb() before and after, so the smp_wmb() on the
> left column is superfluous.

Should I keep it in the comments to make it obvious and add a note
about implicit barriers being the reason we don't call smp_mb() in the
code explicitly?

> The right hand column is actively wrong; because that reads like it
> wants to order a store (g->polling = 0) and a load (d = times[]), and
> therefore requires smp_mb().

Just to clarify, smp_mb() is needed only in the comments or do you
want an explicit smp_mb() in the code as well? As Johannes noted
get_recent_times() which is part of "delta = times[*]" operation
involves read_seqcount section that should act as implicit memory
barrier in the slowpath.

> Also, you probably want to use atomic_t for g->polling, because we
> (sadly) have architectures where regular stores and atomic ops don't
> work 'right'.

Oh, I see. Will do. Thanks!

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

