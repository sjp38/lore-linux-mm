Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87130C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 435E52184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:05:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pTMYdsjV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 435E52184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C57C18E0002; Tue, 29 Jan 2019 13:05:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2FAD8E0001; Tue, 29 Jan 2019 13:05:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46148E0002; Tue, 29 Jan 2019 13:05:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8D18E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:05:20 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id 18so6116817wmw.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:05:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y+ap6Bq9i9Bosxjv/aC11VsPIK0N0Zh2bt/qMaK7RFo=;
        b=JXLx1ttaMrWhBRm+26bdGJz4fEbbWNM670u83O1PjAmogYFMpWZumfyt0JI20MZy4E
         GBfClz5Ll2FuQctqaEfE5xWQzo1WO+bi7eXFr/6sqj51t83eXCxvekGs91XjmOYVM838
         G95jZpChcDR8CwozGa/PVmUoZ3mo+T3TXCh7UuTUIOo57FZnfnRnRiFg3xdeVEEIOMe8
         IG6IvOXw3kh3fRntixZV33pamlx0gfaofaMJnKGknivVNURqXqfER2LHERwHbwxurU0E
         CJg4HVfmkfVHYzhnR8XtCcT3YW18MUv+37iQLSljiwuLJ7oQIkZ4EBz/1tmsPmj169Bx
         BLWw==
X-Gm-Message-State: AHQUAuYZxQSjPzK3eAsJ5Jah7b/X79fgTpbbs+SszxkGUuxJ0JUX+YZX
	8s6BAyg+InrtqXDtcTlGFFZpTy9fi/SM3omUMok90VVGy3rdnM0EyNEhwl76m1TeBT4dGU+f6KF
	VxezVR1GYa85h9U/4nMfF5x3fwzD5UEMHFkBvKHEWBb7zaWLNRXqnnI0pOoztfeB2ntDz13O82e
	Ds7XygWfwYZU6fpFsMCoa2Hg33OkhUU4JjEbwINLNI4JO+UuztWQ1OXRHQtdKC5FmtHBlBYivLJ
	GQxnP5DezlzdoLdzS3OI1UCF5SevWBMReNnEB2nJrxCNe+Xw9ddBsAjwvkWqPumfz4b74uhwVcm
	jFllGjg2ZLTYmbJw4fhs0QrYqYoeuXAvmEElV631YpgmN5SsV4Eqit3kpSfXulDIz+W0TUEBRbu
	U
X-Received: by 2002:a5d:5443:: with SMTP id w3mr4390587wrv.4.1548785119889;
        Tue, 29 Jan 2019 10:05:19 -0800 (PST)
X-Received: by 2002:a5d:5443:: with SMTP id w3mr4390544wrv.4.1548785119122;
        Tue, 29 Jan 2019 10:05:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548785119; cv=none;
        d=google.com; s=arc-20160816;
        b=LN9ku/xHFUUehIa1/JIeNHXrupTXIAJtitIr+S8zCFxSdYrbmuYHhtKEY0aycdlnmT
         67SdUJ9gC6K6/bTPJ3yGrIiOEICBPns2hlb3tVRN6x7KauJn5mrldx9JNlVn6bEBB3dM
         ZkkEO6Ko8QJgl5e4U+w9B7j1P6rVIBY/feBVSNzKgeDgf2pdyBCvDjtV2G6Cd0emZqM6
         y218zy6EkxSqFENaCSg7SOJ19gVDBPPE6VvHdy5yVlHspDj/IufzOrDqOMWwjMP13hfZ
         LGauxwt6MWdXtagB0AgpzjwQME0hU/27DXdutjOrXKKtubjIWpuHwM90ZjzZgK9eF6be
         4mnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Y+ap6Bq9i9Bosxjv/aC11VsPIK0N0Zh2bt/qMaK7RFo=;
        b=lgCniBU0giBrDy0tnXELQnpRxzqsIzmdoByqkO9SaHb+m7H7HeIRRWuDkxnQjva33N
         C+e7MjpVtXyn8CD9vyqbXU8Yy4k2tVEHtyDZXCZugSNB8tZX2dUzuyjry+bS8Smyc1+U
         05RsGZZoflv1sibirtid3JNRK33NCPxAhn9JYTRUTea87SPfx6j/FdlbZo5Nc/njg5De
         kuKlOhug2G9LyDYXOv/w5yw56+lK9gu1O0iFre7KQ2jcOz0MgYgvhMnqYQdgZqOj5SGQ
         MaFJpG9T28GqtC5rO3ii7AJqiNxa3jezq/+SN7UWRH0arEUEJkM4HI4rp1X65/zgJ2Oo
         6hRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pTMYdsjV;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor2270538wmc.11.2019.01.29.10.05.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:05:19 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pTMYdsjV;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y+ap6Bq9i9Bosxjv/aC11VsPIK0N0Zh2bt/qMaK7RFo=;
        b=pTMYdsjVGlPjGB46EzZOJP2ZzDqCQrAqtMKteb4meGoxCxhdPbKwQR1sea+cC+6KTW
         G+seq4FJVEvK5CRhVUtH84btkAFM7Xc4jxG+SDLF8sUlDknTuC2WFvELFSNqQRh3hYCG
         CvcEgmI2ubiEKT3037EZFz8oCFJ9h2vrXZeY/DN5KatkMVTeIUt85CojWalyztZWPCu9
         5UNFCramOZsutLuabzLGoYyV22vjYFlPJrv+sIbEz+foWtJ/T43QYM6ELa5elREGVVhI
         DNszJWv4OwXbAtfHWrgmqegPvT7xs193W6REmvUd1rwEKb5NxMrkXxmOSbFn7DV+Sf2Z
         wrqg==
X-Google-Smtp-Source: ALg8bN7LYSdl+dRdBBbTvxW1GBHoyD6o/TBUVTnGWPtKZpAzgWSqhyM1ZtFKfRYRVtnOYo2pX0CGBDOWEMoPtBdoZiE=
X-Received: by 2002:a7b:c04e:: with SMTP id u14mr20579255wmc.133.1548785118461;
 Tue, 29 Jan 2019 10:05:18 -0800 (PST)
MIME-Version: 1.0
References: <20190124211518.244221-1-surenb@google.com> <20190124211518.244221-6-surenb@google.com>
 <20190129104431.GJ28467@hirez.programming.kicks-ass.net>
In-Reply-To: <20190129104431.GJ28467@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 29 Jan 2019 10:05:07 -0800
Message-ID: <CAJuCfpH3k0rrZZw_HhrjXYuFX31p283qg_5vQEnyd_wAMaxbqA@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
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

Thanks for review Peter!

On Tue, Jan 29, 2019 at 2:44 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> >  static void psi_update_work(struct work_struct *work)
> >  {
> >       struct delayed_work *dwork;
> >       struct psi_group *group;
> > +     bool first_pass = true;
> > +     u64 next_update;
> > +     u32 change_mask;
> > +     int polling;
> >       bool nonidle;
> > +     u64 now;
> >
> >       dwork = to_delayed_work(work);
> >       group = container_of(dwork, struct psi_group, clock_work);
> >
> > +     now = sched_clock();
> > +
> > +     mutex_lock(&group->update_lock);
>
> actually acquiring a mutex can take a fairly long while; would it not
> make more sense to take the @now timestanp _after_ it, instead of
> before?

Yes, that makes sense. As long as *now* is set before the *retry*
label, otherwise the retry mechanism would get even more complicated
to understand with floating *now* timestamp. Will move the assignment
right after the mutex_lock()

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

