Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 365BEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9C3D2080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:31:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="J+vXHO/c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9C3D2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D3948E0002; Tue, 29 Jan 2019 13:31:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9837A8E0001; Tue, 29 Jan 2019 13:31:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8735C8E0002; Tue, 29 Jan 2019 13:31:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0BA8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:31:53 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v16so8108035wru.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:31:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0m3skRRv8gGXarJnQx7v/9n5i4k4SmQKxcZwANz4wvY=;
        b=MxPxoZm0TC0Ia2NlAire6N1drHfixhqtb4e9a1uOskwUfkK3bvLHx0hOR5bes8N+Ac
         egv8BzhGJwLO1s40xrJgMWDHqeYlWQHVo0jC1noTV7a/zhfs/xYBiBpKCbsME0nhMiEf
         jV9y1LSxeOk4hFa3km0ooLDk9HTOG9iA53DjXTJz4t6WuYm7dlHUUnA3d8eRq0+1h6em
         3KWhsctQxg8T6fy3E31s1qHKrJvWSHLAUECLxoAJUNVLR22FXMJDYf237OeUCVX8DaYw
         EOkQmapOwT51o6vUpKP225uj4wWvB2bOnFekg86DiC+yFT8MTkioMLk5/9lYCv0KhgCi
         chEQ==
X-Gm-Message-State: AJcUukdwgvHQaGrqw9qSd0ftDeY+Df47A3p6b1Z5cno6y4MAc3PbWkDW
	CFY80qwm7x5Rvzh1qjAs8vn2ag0ncyG/hsFD1YUuty/Wv573u/H3X5nTVgFCzC5LskK0rzUVbdW
	3OGIijKTuCcMvOwsBPNRXSwkYmnxiy2FpOmvreJZ8TLUbjEuc25mz0biXgTaAGeQyx6tUh64PBd
	OPaAoYZ6HsaXLo5oJo8NOTUs18bK4ugujHmcwOJ/hNNc/epoNU+skoOqln6TSBcX8SJytVZASRy
	/aG6xPuvHGLY302TkSI0W1qED3vr1ErnrHEAomfv6Hjiy1wZ2yiHXbR/V1iFKLaKXAkZfeSvKOW
	LCNG/KKEdJ9+lNS4ZamMEfuDKBhhWn5e0ny8jKe4N+KOUZU/EDpTP5M34G6ZnAkgzibNpP4BbMK
	Z
X-Received: by 2002:a1c:b456:: with SMTP id d83mr23172504wmf.115.1548786712710;
        Tue, 29 Jan 2019 10:31:52 -0800 (PST)
X-Received: by 2002:a1c:b456:: with SMTP id d83mr23172473wmf.115.1548786711961;
        Tue, 29 Jan 2019 10:31:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786711; cv=none;
        d=google.com; s=arc-20160816;
        b=ndiPxRDrYK4rzfBEqz6dMsNwEgF95N5Ywh/+4Xc0rHsrpJChJz3TEez7mJ60bGYbSx
         ZmN2SueV3FfsMTWrVjEs2lcOY9/fnbCVPXReicHYLDvy3QfKvpma8w7jpgL72vLf/B82
         iEy5apoaff7+Yya5QIIvK8OqZJHICALr5oSHQ77xCY47kauykO3IdO+3ZVK1A/rOjlQE
         DHS6JMdiYaq9d8UuVM1GR09ef+DPBQa1kpiEqkxyaM2F01hQKfaPwcOxJAuM70guhZ7y
         ZD3obQh+4kYlj6Gl5/V7i/96jEVPK/UM6si57U+alN6ZdPiXyZ1vd9+u+DaCuBGFarNW
         dVUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0m3skRRv8gGXarJnQx7v/9n5i4k4SmQKxcZwANz4wvY=;
        b=QV17TnLe19QmPfrAYztPEIFbOe1M/8TcyW2H+Pk4XU3h56SwT0m+0IZJYIx5VKLPsT
         MY8cmeR8VkomBDBz2MOf3nXoh/SK1uB1pARIjY7RlFbzoMrwNk44d4DwOMsoiLLe1j92
         xJtz+aR4rSVDWLr7CiMlnwfLYMQvShtiK+he/rA1wjinHGzVVBK4BseL0zJau3yTpBhh
         5Q1vPQYMkWVEiDiy6le5v4+yBakbDoMaSFgT3l5MPApZSCjYrVm6wCE2bIY/thh6bHfc
         MyPKXoCLIu82qFXDwZ0y687W+cu/IdhwvBwvSy1y+XxbdHvNhXkDFuIPW4KhljoPGkIh
         qulg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="J+vXHO/c";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93sor82115566wrb.13.2019.01.29.10.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:31:51 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="J+vXHO/c";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0m3skRRv8gGXarJnQx7v/9n5i4k4SmQKxcZwANz4wvY=;
        b=J+vXHO/cVQyn/1ZJqpK6skQGqPQVpUQSFTHNxOQ/z+6XxcF12Z91kemu2Nn9BKNMUz
         VP2EBsuvQUqdG6OJx/S2GiAKnWo+P7aQJs+XX8IYSA27JNRhIyd5zPGOuA4KgMsq7Kee
         QiadlZ0vaoAxeOniQYEFw+UqJTxEOOafgjs+b2yXFkK417Qtr48IV6RG7VIffB2j+Njb
         c7cVImBJqH3RrxBu4gbUXHt5GgzGTblW6m3mg+uCtQfvUNk0vGUqQKmZ3QJ8lvIbM0cH
         QoErGjgId+U39N2tUYBt2csNLu2AJeqjLyj3WU/Qlx6fW9iBFyqFB9iWtV5dL84G55L8
         HcUw==
X-Google-Smtp-Source: AHgI3Ibx6/OVbETdDnoEV80C1606vDQP1T/8S7POacnT0d0ekLrAVuNZHS4p8b+VSew2Gru4p8xK+9b8kamEI0pS2KE=
X-Received: by 2002:adf:dc4e:: with SMTP id m14mr7291068wrj.107.1548786711280;
 Tue, 29 Jan 2019 10:31:51 -0800 (PST)
MIME-Version: 1.0
References: <20190124211518.244221-1-surenb@google.com> <20190124211518.244221-6-surenb@google.com>
 <20190129123843.GK28467@hirez.programming.kicks-ass.net> <CAJuCfpGxtGHsow002nd8Ao8mo9MaZQqZau_NLTMrZ8=aypTkig@mail.gmail.com>
In-Reply-To: <CAJuCfpGxtGHsow002nd8Ao8mo9MaZQqZau_NLTMrZ8=aypTkig@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 29 Jan 2019 10:31:40 -0800
Message-ID: <CAJuCfpHdtY7cRBfVP-+e9hQrTigStj2XK_qpk8z91HSKW+Y5WA@mail.gmail.com>
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

On Tue, Jan 29, 2019 at 10:18 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Tue, Jan 29, 2019 at 4:38 AM Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > > +                     atomic_set(&group->polling, polling);
> > > +                     /*
> > > +                      * Memory barrier is needed to order group->polling
> > > +                      * write before times[] read in collect_percpu_times()
> > > +                      */
> > > +                     smp_mb__after_atomic();
> >
> > That's broken, smp_mb__{before,after}_atomic() can only be used on
> > atomic RmW operations, something atomic_set() is _not_.
>
> Oh, I didn't realize that. After reading the following example from
> atomic_ops.txt I was under impression that smp_mb__after_atomic()
> would make changes done by atomic_set() visible:
>
> /* All memory operations before this call will
> * be globally visible before the clear_bit().
> */
> smp_mb__before_atomic();
> clear_bit( ... );
> /* The clear_bit() will be visible before all
> * subsequent memory operations.
> */
> smp_mb__after_atomic();
>
> but I'm probably missing something. Is there a more detailed
> description of these rules anywhere else?

I was referred to memory-barriers.txt that explains this clearly
stating that "These functions do not imply memory barriers.". Thanks
for noticing! Will change to smp_mb().

> Meanwhile I'll change smp_mb__after_atomic() into smp_mb(). Would that
> fix the ordering?
>
> > --
> > You received this message because you are subscribed to the Google Groups "kernel-team" group.
> > To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
> >

