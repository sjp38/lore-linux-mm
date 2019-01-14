Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32C9AC43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 20:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B65D8206B7
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 20:48:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="A2pDQgPM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B65D8206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14AC48E0003; Mon, 14 Jan 2019 15:48:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FB098E0002; Mon, 14 Jan 2019 15:48:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0106E8E0003; Mon, 14 Jan 2019 15:48:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE2F8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:48:02 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id p12so110357wrt.17
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 12:48:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jwW1KirWJa3Otm0mdb+FxZ3AFbnGbcDi8Iugc6Rltwo=;
        b=DgvDxHZJZYhg+yKEkZzAD4TxXepuNn8cnrRPCDuIbx3yo/CedRBrsuph370li3rxsj
         v82jB9D0RbnZ6YfAsGefAIxDmncIv15DrL+UdCRfKVNHqZPzeSTB5J38img+QhIHI4z+
         0TjfaIYiYqg0D5jRdA7vn9ddQe0IKm1kHKYhVOWQPTMiWx+xYulNNmTCmea4EQkgW8u2
         Vm+GPQ16eTCYFpozte+1/OMp6rxGm5GNdT0dE7xZLXcogRoEbHlL/xYEjKqfPMctdgb6
         JSgBcYyfBNmrTK3QKqY8SnOd437bJnjaeNTXzaQebqv1rQTGcYLEBWyUPJ05E9I1BJrd
         51iQ==
X-Gm-Message-State: AJcUukcF5G5V2RXYim+g+NqbRv8h61c03oC6oRg5RcULAQuS5Em00fQ6
	XvVRadnVI03NST0LXoJLfEcPE/twvjt60PMzK3dJbVfenuWtsZi75KJN2uJoXVgY8IFmypuj9JR
	58O+JFqwfSIzy3t5ZFmCHMzdCqDxe+YlN/QpP5QOoWAmix1WOqh4Ja3dCDegT8nUQ0pO/kb4BEv
	MEI9iEf3KidXJllB8IcFIrLbY0zgFc0DUtpgBvdeJpSdXRa/NQrWJizJ7hgpo8ZZF3EBuGYavET
	UlZdJEN8CEvTjVzQtZ70CaXyDZUftxoRACUQIF7ApbpG/ACx+u8/N65hOEtnWJOOXpx1eDW6Y/X
	gHxT8icoG0uXj2q7lh8Ta3bLJRet/+Na4sgSqs0tcfdT/pvjX9zN5Mc+kfqEO3QCgQsafmggkfx
	E
X-Received: by 2002:a1c:6442:: with SMTP id y63mr645834wmb.143.1547498882051;
        Mon, 14 Jan 2019 12:48:02 -0800 (PST)
X-Received: by 2002:a1c:6442:: with SMTP id y63mr645793wmb.143.1547498880865;
        Mon, 14 Jan 2019 12:48:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547498880; cv=none;
        d=google.com; s=arc-20160816;
        b=qFEsh95RUC3ZrD4k3yPzbXucWAIoZxL/+kfYf7aZol+MrZayTwNQ0tTdYD4W8SoMAh
         0IzwcYWB0pgxoF5MIQwKwkInH2TNfbeT8YxXdrdwufJWtkXmI4seTU3OfpVDwbEVp7ea
         AhshNIC6DMxDZ0uvNOQXEgsYEXXP4Q8HSiN6hrglIbONPDY0maKCLjwpvgswU/glmqsC
         vpDSTGwAkvfLW6V80W8ZFdEFsyc5V87wwK7LQRNdLWnNi+2HVjfN6elIKsWz9I01rBw9
         Zz1kVHp+8CixpE+0sBx3Cc/6/ZL+9MZdbrb6pLJZCgks6kxkO6bAdkdQg2+IYCzcP7Tk
         uJGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jwW1KirWJa3Otm0mdb+FxZ3AFbnGbcDi8Iugc6Rltwo=;
        b=fEivzkeMOwItu6YzDNJKniJnA5SgvBSeDywvD5mwaxzSHi78/L9vH4LHKtF6RCJbYq
         waum9m2kZn7hadZBhpXm2bhUKh75PtBQpCqjO2V8FO218LW1ZaQpHEZjck6JuVu/l1p8
         dzLYv0X/53HkuwHy9BnfrLgZ1hKYUWmfbpgBgWXmiD0z9WgtvZX3NXjmBW+JdRr1HkgV
         D2Ap153xrK77OzHG6q1JT3sLYiNLcp+Z9r9PsH33K7WuAGBJS+UDL3q1NekgE+noKjUd
         OxdpEKVIAlH8o2GTIjQdrMaulwD3LmEBawqLL1g+uJDx/3PMbd1cWdkIpyIcnJr5alwO
         9xpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A2pDQgPM;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q186sor19359863wme.15.2019.01.14.12.48.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 12:48:00 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A2pDQgPM;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jwW1KirWJa3Otm0mdb+FxZ3AFbnGbcDi8Iugc6Rltwo=;
        b=A2pDQgPMfi8xEcPmWoQZ2vTIY4giMrEqTxyGbkzbS3KIpKn4Rzshn3bvn+6sjPR4v/
         z3eeTNO9KIL13+ffxR2gzEQ6VTGx2Qoefby8azX1xOvMmP1uqyVMPFpL5OBzd/aHEHiG
         gx/yvd/XHBODmMQ73oi3WtAGNEhSTdeQSF0uJWHEHIaqeThB2Vc1CMPdWBarjpe/2Op1
         FnIgnpfClFuK1z7GZIKdpc+2vIwVQrXeSYp4uL6yiI4/MRtFXHeyNuhQHreQFcK57G0f
         z1+JznRXHIrhESLyl/fpth4COZ/LcDv2W0XMR+hBn5T5ug+ZzV329WtQ4EHSmGk27xid
         r6sA==
X-Google-Smtp-Source: ALg8bN7iurn1V/oAb9TPOfzDB1cZrLk7Mb7Ob0iavv3WLprDDiWHghw3bxnNBUClL+Yo6cWdjUkw7edud95FQv0DClc=
X-Received: by 2002:a1c:e910:: with SMTP id q16mr717314wmc.68.1547498879880;
 Mon, 14 Jan 2019 12:47:59 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com> <20190114194222.GA10571@cmpxchg.org>
In-Reply-To: <20190114194222.GA10571@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 14 Jan 2019 12:47:48 -0800
Message-ID:
 <CAJuCfpF+eZFxCuB4QtQDOeDFYRg1LBiAKkF6QZxRk-FenkNu7w@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] psi: introduce psi monitor
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Tejun Heo <tj@kernel.org>, lizefan@huawei.com, axboe@kernel.dk, dennis@kernel.org, 
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
Message-ID: <20190114204748.549WTeGR0sCYG7MlG4js954oPSx3_CTgS1cGkL6XQ_E@z>

On Mon, Jan 14, 2019 at 11:42 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Mon, Jan 14, 2019 at 11:30:12AM -0800, Suren Baghdasaryan wrote:
> > On Mon, Jan 14, 2019 at 2:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > >
> > > On Thu, Jan 10, 2019 at 02:07:18PM -0800, Suren Baghdasaryan wrote:
> > > > +/*
> > > > + * psi_update_work represents slowpath accounting part while
> > > > + * psi_group_change represents hotpath part.
> > > > + * There are two potential races between these path:
> > > > + * 1. Changes to group->polling when slowpath checks for new stall, then
> > > > + *    hotpath records new stall and then slowpath resets group->polling
> > > > + *    flag. This leads to the exit from the polling mode while monitored
> > > > + *    states are still changing.
> > > > + * 2. Slowpath overwriting an immediate update scheduled from the hotpath
> > > > + *    with a regular update further in the future and missing the
> > > > + *    immediate update.
> > > > + * Both races are handled with a retry cycle in the slowpath:
> > > > + *
> > > > + *    HOTPATH:                         |    SLOWPATH:
> > > > + *                                     |
> > > > + * A) times[cpu] += delta              | E) delta = times[*]
> > > > + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> > > > + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now +
> > > > + *                                     |              grace_period
> > > > + *                                     |    if now > polling_until:
> > > > + *    if start_poll:                   |      if g->polling:
> > > > + * C)   mod_delayed_work(1)            | G)     g->polling = polling = 0
> > > > + *    else if !delayed_work_pending(): | H)     goto SLOWPATH
> > > > + * D)   schedule_delayed_work(PSI_FREQ)|    else:
> > > > + *                                     |      if !g->polling:
> > > > + *                                     | I)     g->polling = polling = 1
> > > > + *                                     | J) if delta && first_pass:
> > > > + *                                     |      next_avg = calculate_averages()
> > > > + *                                     |      if polling:
> > > > + *                                     |        next_poll = poll_triggers()
> > > > + *                                     |    if (delta && first_pass) || polling:
> > > > + *                                     | K)   mod_delayed_work(
> > > > + *                                     |          min(next_avg, next_poll))
> > > > + *                                     |      if !polling:
> > > > + *                                     |        first_pass = false
> > > > + *                                     | L)     goto SLOWPATH
> > > > + *
> > > > + * Race #1 is represented by (EABGD) sequence in which case slowpath
> > > > + * deactivates polling mode because it misses new monitored stall and hotpath
> > > > + * doesn't activate it because at (B) g->polling is not yet reset by slowpath
> > > > + * in (G). This race is handled by the (H) retry, which in the race described
> > > > + * above results in the new sequence of (EABGDHEIK) that reactivates polling
> > > > + * mode.
> > > > + *
> > > > + * Race #2 is represented by polling==false && (JABCK) sequence which
> > > > + * overwrites immediate update scheduled at (C) with a later (next_avg) update
> > > > + * scheduled at (K). This race is handled by the (L) retry which results in the
> > > > + * new sequence of polling==false && (JABCKLEIK) that reactivates polling mode
> > > > + * and reschedules next polling update (next_poll).
> > > > + *
> > > > + * Note that retries can't result in an infinite loop because retry #1 happens
> > > > + * only during polling reactivation and retry #2 happens only on the first
> > > > + * pass. Constant reactivations are impossible because polling will stay active
> > > > + * for at least grace_period. Worst case scenario involves two retries (HEJKLE)
> > > > + */
> > >
> > > I'm having a fairly hard time with this. There's a distinct lack of
> > > memory ordering, and a suspicious mixing of atomic ops (cmpxchg) and
> > > regular loads and stores (without READ_ONCE/WRITE_ONCE even).
> > >
> > > Please clarify.
> >
> > Thanks for the feedback.
> > I do mix atomic and regular loads with g->polling only because the
> > slowpath is the only one that resets it back to 0, so
> > cmpxchg(g->polling, 1, 0) == 1 at (G) would always return 1.
> > Setting g->polling back to 1 at (I) indeed needs an atomic operation
> > but at that point it does not matter whether hotpath or slowpath sets
> > it. In either case we will schedule a polling update.
> > Am I missing anything?
> >
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
>
> delta = times[*] is get_recent_times(), which uses a seqcount and so
> implies the smp_rmb() already as well. So we shouldn't need another
> explicit one. But the comment should point out all the barriers.

Got it, thanks!
How about changing the comment this way:

   HOTPATH:                         |    SLOWPATH:
                                    |
A) times[cpu] += delta              | E) delta = times[*]
   smp_wmb()                        |    if delta[poll_mask]:
B) start_poll = (delta[poll_mask] &&| F)   polling_until = now + grace_period
     cmpxchg(g->polling, 0, 1) == 0)|    if now > polling_until:
   if start_poll:                   |      if g->polling:
C)   mod_delayed_work(1)            | G)     g->polling = polling = 0
   else if !delayed_work_pending(): |        smp_rmb()
D)   schedule_delayed_work(PSI_FREQ)| H)     goto SLOWPATH
                                    |    else:
                                    |      if !g->polling:
                                    | I)     g->polling = polling = 1
                                    | J) if delta && first_pass:
                                    |      next_avg = calculate_averages()
                                    |      if polling:
                                    |        next_poll = poll_triggers()
                                    |    if (delta && first_pass) || polling:
                                    | K)   mod_delayed_work(
                                    |          min(next_avg, next_poll))
                                    |      if !polling:
                                    |        first_pass = false
                                    | L)     goto SLOWPATH

And maybe adding a comment about implied memory barriers in cmpxchg()
and in seqlock.
Would that be enough?

