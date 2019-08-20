Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D0B2C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD40214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A+evG0gI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD40214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 486F16B0007; Tue, 20 Aug 2019 03:16:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438806B0008; Tue, 20 Aug 2019 03:16:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34CFB6B000A; Tue, 20 Aug 2019 03:16:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0225.hostedemail.com [216.40.44.225])
	by kanga.kvack.org (Postfix) with ESMTP id 14AA56B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:16:33 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6CDA98E4F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:16:32 +0000 (UTC)
X-FDA: 75841948224.24.beast86_390f1cac07960
X-HE-Tag: beast86_390f1cac07960
X-Filterd-Recvd-Size: 6183
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:16:31 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id p12so7629776iog.5
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:16:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0qWPexWw+CqnDIQoK/jbmNOWBMIDflLMoHxHdzY5f+I=;
        b=A+evG0gI+H+qKt4QkO9qMkzP80EyzXo54EPJif4uxy1PFkWzthFSs7IcO1Ug4swHHU
         aeSDLyeirhgFQxSQ5Pa+96tsQVijxAGg9Sio1CWMxgtRZg1ogYFWbE8b2XU1SLUu6WTZ
         e7XbSj6lGii/2hxS53+ZTv16ViRv7EXTPxf4gWwhvAR5FVq1CsLKeZupvZm/40JMy4YL
         ++RnvNkYoSJGhbfWz/I/PQjY7/JGLL9B+EP3Fbt2GvTCrj9oQ7HV/PM3/Y6BQZN4HhYe
         9Kycm/rxv7DkJaW30AVgM70Z2lLy8cSNtRUa42WMm/f2tSpIhqf8mGW1IhEo6Z9jWc7p
         Dixg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0qWPexWw+CqnDIQoK/jbmNOWBMIDflLMoHxHdzY5f+I=;
        b=CWo6BLxlIXfXpHxkW42th0t6Je2NB+aY9l5viAEJe7WK7e0VNgjpX7L8b584AW00xf
         JsFwqJ3LThCfnGxBAozPE5uhndFUwoYj7HJjeiiJ68hxCJ55pTrErF1+nfvj6ERiJg0N
         lOYLMOArUi7qRJRXd+oFeLLzCdlkPiEWu2walLuybavSfYl9njk60KTXZxjjHRSG3C4Y
         adyFD/Y6piT4Ku4AtKTZJ7b8sCLI4yL8q9lgt8axOqgX+eRa2eoCJDVGvGAfJ12FjeJ7
         W74WwBxMsnpRJrwWbhwhzvPgCeVQNuunXIrpSMGBPXoi8aekhGoHjGMk8CkWtqkUFq2S
         +CKQ==
X-Gm-Message-State: APjAAAX3tiwlyZswoxDk/a8NKipNhrTqfLgjaMYwbce1J9j2eaX5ZOux
	EhFuC5EEITuig1u0g0ruZugJv0bQ+Kdnlyx1Wvo=
X-Google-Smtp-Source: APXvYqyEvV8r0Peyeum5PB6GzHiyP8iR0c8HdO8Os0UzrKtgMIvY7C4xi6fINNSnZa01nnzQSt848fRcffbVgJwXZ1s=
X-Received: by 2002:a05:6602:224a:: with SMTP id o10mr15476199ioo.44.1566285391430;
 Tue, 20 Aug 2019 00:16:31 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com> <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz>
In-Reply-To: <20190820064018.GE3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 15:15:54 +0800
Message-ID: <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 2:40 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > In the current memory.min design, the system is going to do OOM instead
> > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > system is lack of free memory. While under this condition, the OOM
> > > > killer may kill the processes in the memcg protected by memory.min.
> > > > This behavior is very weird.
> > > > In order to make it more reasonable, I make some changes in the OOM
> > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > skip the processes under memcg protection at the first scan, and if it
> > > > can't kill any processes it will rescan all the processes.
> > > >
> > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > problem because this only happens under system  memory pressure and
> > > > the OOM killer can't find any proper victims which are not under memcg
> > > > protection.
> > >
> > > Hi Yafang!
> > >
> > > The idea makes sense at the first glance, but actually I'm worried
> > > about mixing per-memcg and per-process characteristics.
> > > Actually, it raises many questions:
> > > 1) if we do respect memory.min, why not memory.low too?
> >
> > memroy.low is different with memory.min, as the OOM killer will not be
> > invoked when it is reached.
>
> Responded in other email thread (please do not post two versions of the
> patch on the same day because it makes conversation too scattered and
> confusing).
>
(This is an issue about time zone :-) )

> Think of min limit protection as some sort of a more inteligent mlock.

Per my perspective, it is a less inteligent mlock, because what it
protected may be a garbage memory.
As I said before, what it protected is the memroy usage, rather than a
specified file memory or anon memory or somethin else.

The advantage of it is easy to use.

> It protects from the regular memory reclaim and it can lead to the OOM
> situation (be it global or memcg) but by no means it doesn't prevent
> from the system to kill the workload if there is a need. Those two
> decisions are simply orthogonal IMHO. The later is a an emergency action
> while the former is to help guanratee a runtime behavior of the workload.
>

If it can handle OOM memory reclaim, it will be more inteligent.

> To be completely fair, the OOM killer is a sort of the memory reclaim as
> well so strictly speaking both mlock and memcg min protection could be
> considered but from any practical aspect I can think of I simply do not
> see a strong usecase that would justify a more complex oom behavior.
> People will be simply confused that the selection is less deterministic
> and therefore more confusing.
> --

So what about ajusting the oom_socore_adj automatically when we set
memory.min or mlock ?

Thanks
Yafang

