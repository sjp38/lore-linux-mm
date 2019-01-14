Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75B81C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 19:30:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24EF72064C
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 19:30:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LTdpmr7i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24EF72064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B70C98E0003; Mon, 14 Jan 2019 14:30:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B20668E0002; Mon, 14 Jan 2019 14:30:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A36678E0003; Mon, 14 Jan 2019 14:30:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3268E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:30:26 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id 51so39762wrb.15
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:30:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V7Nld/m9dECZLpYS+KOKxjAa17WRgnctGhf+2cl141w=;
        b=nUWqrNGyZL8fgxQJDA6yPm2ym791TJn1nMZuhG9yaDJ0NJNtBeZsdOtyU+tj3ydznn
         jP6TBVHHUjcuHGE+HnT41f/eTGJDUVABetO4nUq757oMe6Xi9UVhVk7s4VweEE6IgJL1
         yZ/C4BYm9qHdAg54jvzsRyiNApjDlYb3lSc0Q2pSZNuCtZozlumejkwHyPTeMBTsETeB
         hJUJjl6kc+YnuR7NB0sHPBNUPkM2vTlLNZDgHVypE/Ks6xbrOlcZRvxREQqBdE91c3Vy
         AWJva0AkpNCLdHpkJikuK7NV3pZWhqKjq/JzKzAWIW5LzPrh4cdtaWXOKGiOphScnrT2
         tdXQ==
X-Gm-Message-State: AJcUukeoI6vhofxa/dxSOus7fSGa1DNtsoXbfO8Co4LqyBzfVkq9hJhw
	HI0jbmqS0yxA92it1NcZYURU6L7MtDErg4Z+og4dWZiZ32XtKqMctAIYeV5ifTkaho7F4sY4C2j
	5AWuEr+yMhIF6kjzd6P6jIHKEOz8l/2m9ahWF1xSt+pWp386EMn4qEY7P/2ynP7BRJB1wpBjeyD
	/BB7FnLmmYVOrzH+Nd7cM9CGGHHwDoT4deHsCAF6659wzPCiLGUS6Au+nhYr5nPgqNgyj74SMs+
	erdCpN5HHNhQWd0gDxGaYsevOjGnDf0PoGVa5O+kqDqWP7c2JHecwyrqarcZsEA/y2yDcOjYpbC
	t/kaWBarJPIPbawrtsPI/d3Cv6fQCo99CAA92fmPxu4Y4o+YxhQginZyJf5o0/TJ5atDy9GtUvM
	e
X-Received: by 2002:a1c:b687:: with SMTP id g129mr492039wmf.59.1547494225855;
        Mon, 14 Jan 2019 11:30:25 -0800 (PST)
X-Received: by 2002:a1c:b687:: with SMTP id g129mr491992wmf.59.1547494224816;
        Mon, 14 Jan 2019 11:30:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547494224; cv=none;
        d=google.com; s=arc-20160816;
        b=qZdgpvpZMz6NJtZY2ulidHhNItXMmGypS0yfheme82NL42ZWTbhUEsxFPUhdiaGH1T
         nuBzmLdyOhagki1neH4hCEuGEUwhnmF40mGlo9s9+QvvyfnaKVKY2mhXDaznfSPhWIkI
         zUq+eJZoOlQclQ2+QSVlU1pVvhxLmD3uh4LiNolsxA9gt5+022+bi1jqw11BsHaCuH1b
         LfDrdpF3oA0DQVbtrcrosq4Rii3RX14Y69rxhV3//NmrsApT5mS9doiyQlfV7HZHOUvx
         ASWmgsux/2GIeKOF4EKuqny3E/kGvFuc2AclLbdUnDH3VO455jTrS0CfSFjw36Un4D5z
         ZdPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V7Nld/m9dECZLpYS+KOKxjAa17WRgnctGhf+2cl141w=;
        b=bTBDg7iCQxrTSUyweaZl5UgrdnG/2aXOtag9IBtUNwdM97f+Y47XOKhbsAkxhPr5oQ
         kHzFuykgqVY8nCfKqhK5VQmMCxk1XHqy9wV4AOKHxCMCAvYbSMR2CI6UcNmBpJqlhN/E
         jDVDVuGkzUpqVXBhlKvI9dwU9jod7rpwc41ZHe7XqDwrd3qontk8Rrj2JesWbnOGVw6M
         zhb8csVrf9O5S4ZLKnpqjH2bQboQbqksenUsDR2I8T6nAeSAbhfa3faLamTPCWhsjpSB
         9PSzSq5r9GnFDq770vLGhlVxrNwYvxTUxJDHSf3i2j8+52uNzRkGcZh7J8yhfvv8vEsZ
         1JzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LTdpmr7i;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor49420335wro.6.2019.01.14.11.30.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 11:30:24 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LTdpmr7i;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V7Nld/m9dECZLpYS+KOKxjAa17WRgnctGhf+2cl141w=;
        b=LTdpmr7iYb+51Ff7+r2qP/Jw2u8ZRJFk77VCkLCCiA/ANUAVLSsCEHHlNFOKFkEwnD
         rxV7NnDpIhv7eJ+Y/9f7Iuok4tIdFaSDBWG3QChNJ8RlE2bArnmE+J4ig2eAqeCDIrA3
         jjQuOc8YmNbAupjvk5iECrrfxoqfba70+VzYHLoB8hFfCP3mS0r34T7J1PWePGNK9iDh
         t4Gm5BhbYr8c4rOv07T+KyS8HI/q9jrOW9ijC873iQAKVsVgbcHtRN8VCyKQ8Csd3NSm
         OplHhfMZZn83IGt7jkFnKt2soK1fIUBMXub+E85LXFf1Mn5znpEXQqjmHtygPCW7DB2l
         OYKw==
X-Google-Smtp-Source: ALg8bN6zwKZcThH+o+SBsAintWmrcGydROfOrohi8vkW1zna6VHepdzbVgey6gGzGvNUXUo29kRjKBoH/sqTpKlTCv4=
X-Received: by 2002:adf:de91:: with SMTP id w17mr38740wrl.320.1547494224091;
 Mon, 14 Jan 2019 11:30:24 -0800 (PST)
MIME-Version: 1.0
References: <20190110220718.261134-1-surenb@google.com> <20190110220718.261134-6-surenb@google.com>
 <20190114102137.GB14054@worktop.programming.kicks-ass.net>
In-Reply-To: <20190114102137.GB14054@worktop.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 14 Jan 2019 11:30:12 -0800
Message-ID:
 <CAJuCfpGUWs0E9oPUjPTNm=WhPJcE_DBjZCtCiaVu5WXabKRW6A@mail.gmail.com>
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
Message-ID: <20190114193012.QTg6Lp0Fs96gFV7MQLsYKyH8Tt-Y5Y323l6Qlf3F4RA@z>

On Mon, Jan 14, 2019 at 2:22 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Thu, Jan 10, 2019 at 02:07:18PM -0800, Suren Baghdasaryan wrote:
> > +/*
> > + * psi_update_work represents slowpath accounting part while
> > + * psi_group_change represents hotpath part.
> > + * There are two potential races between these path:
> > + * 1. Changes to group->polling when slowpath checks for new stall, then
> > + *    hotpath records new stall and then slowpath resets group->polling
> > + *    flag. This leads to the exit from the polling mode while monitored
> > + *    states are still changing.
> > + * 2. Slowpath overwriting an immediate update scheduled from the hotpath
> > + *    with a regular update further in the future and missing the
> > + *    immediate update.
> > + * Both races are handled with a retry cycle in the slowpath:
> > + *
> > + *    HOTPATH:                         |    SLOWPATH:
> > + *                                     |
> > + * A) times[cpu] += delta              | E) delta = times[*]
> > + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> > + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now +
> > + *                                     |              grace_period
> > + *                                     |    if now > polling_until:
> > + *    if start_poll:                   |      if g->polling:
> > + * C)   mod_delayed_work(1)            | G)     g->polling = polling = 0
> > + *    else if !delayed_work_pending(): | H)     goto SLOWPATH
> > + * D)   schedule_delayed_work(PSI_FREQ)|    else:
> > + *                                     |      if !g->polling:
> > + *                                     | I)     g->polling = polling = 1
> > + *                                     | J) if delta && first_pass:
> > + *                                     |      next_avg = calculate_averages()
> > + *                                     |      if polling:
> > + *                                     |        next_poll = poll_triggers()
> > + *                                     |    if (delta && first_pass) || polling:
> > + *                                     | K)   mod_delayed_work(
> > + *                                     |          min(next_avg, next_poll))
> > + *                                     |      if !polling:
> > + *                                     |        first_pass = false
> > + *                                     | L)     goto SLOWPATH
> > + *
> > + * Race #1 is represented by (EABGD) sequence in which case slowpath
> > + * deactivates polling mode because it misses new monitored stall and hotpath
> > + * doesn't activate it because at (B) g->polling is not yet reset by slowpath
> > + * in (G). This race is handled by the (H) retry, which in the race described
> > + * above results in the new sequence of (EABGDHEIK) that reactivates polling
> > + * mode.
> > + *
> > + * Race #2 is represented by polling==false && (JABCK) sequence which
> > + * overwrites immediate update scheduled at (C) with a later (next_avg) update
> > + * scheduled at (K). This race is handled by the (L) retry which results in the
> > + * new sequence of polling==false && (JABCKLEIK) that reactivates polling mode
> > + * and reschedules next polling update (next_poll).
> > + *
> > + * Note that retries can't result in an infinite loop because retry #1 happens
> > + * only during polling reactivation and retry #2 happens only on the first
> > + * pass. Constant reactivations are impossible because polling will stay active
> > + * for at least grace_period. Worst case scenario involves two retries (HEJKLE)
> > + */
>
> I'm having a fairly hard time with this. There's a distinct lack of
> memory ordering, and a suspicious mixing of atomic ops (cmpxchg) and
> regular loads and stores (without READ_ONCE/WRITE_ONCE even).
>
> Please clarify.

Thanks for the feedback.
I do mix atomic and regular loads with g->polling only because the
slowpath is the only one that resets it back to 0, so
cmpxchg(g->polling, 1, 0) == 1 at (G) would always return 1.
Setting g->polling back to 1 at (I) indeed needs an atomic operation
but at that point it does not matter whether hotpath or slowpath sets
it. In either case we will schedule a polling update.
Am I missing anything?

For memory ordering (which Johannes also pointed out) the critical point is:

times[cpu] += delta           | if g->polling:
smp_wmb()                     |   g->polling = polling = 0
cmpxchg(g->polling, 0, 1)     |   smp_rmb()
                              |   delta = times[*] (through goto SLOWPATH)

So that hotpath writes to times[] then g->polling and slowpath reads
g->polling then times[]. cmpxchg() implies a full barrier, so we can
drop smp_wmb(). Something like this:

times[cpu] += delta           | if g->polling:
cmpxchg(g->polling, 0, 1)     |   g->polling = polling = 0
                              |   smp_rmb()
                              |   delta = times[*] (through goto SLOWPATH)

Would that address your concern about ordering?

> (also, you look to have a whole bunch of line-breaks that are really not
> needed; concattenated the line would not be over 80 chars).

Will try to minimize line-breaks.


> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

