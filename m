Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 888A0C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 397EE2148D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:50:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Krm9mepJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 397EE2148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D19276B000D; Tue, 23 Apr 2019 12:50:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF14A6B000E; Tue, 23 Apr 2019 12:50:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE8C6B0266; Tue, 23 Apr 2019 12:50:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFDE6B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:50:07 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k6so13640382qkf.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=58QZAQnPWCJXaIZAo7dlCzisiH33M4fciKPxNT+NHWI=;
        b=j3Rzf4A+3DUbVE3kP4nbClV2tP3hp/b0coBhZPeemQNz0LAkBz8KUTzJbLgFQZfKG2
         RkJwIBLEUkeLncBgJazfbOKNJjMEgYMHh9z8j0ZCpPOKjGp0XHLykAX+J3YoC3B/jTK8
         m53ZIMgoeSdS6RuMEUAIoAUJM7iZidxCYX+vkcOovt+t0a/EuNhA+umiUzF4fL2qN4ro
         ctcV6L589hHqVKFHF8haf3z4mYoyXo2nMy+CS8l07rWDZ2LXFa/9GGRTg0i16rO2X33O
         wT/lQEssyOt+JEsZOAzX7LePC38beZClMLZr5iXJJUkXdI7eeAn9qsA1XI/T6vAfdngj
         WKqA==
X-Gm-Message-State: APjAAAUUkvYm604FRJfxDkMPfFR/tXCbU6BTDyVqNi8BO7C3Hf1VX6W7
	VbxLq9x5b066EtL/bnxmHkyjL3waIM8dHS+4oWlQ9eskyaMcKAcczsqfE3y4vC3uT007Ypw8kgZ
	N+VBdyAwCePaTSTWj3OmIJpl224AFquaP9JOjCeYRCuZq6OwNWdnKRlaFJXMjGn6hcg==
X-Received: by 2002:ac8:742:: with SMTP id k2mr3542590qth.346.1556038207362;
        Tue, 23 Apr 2019 09:50:07 -0700 (PDT)
X-Received: by 2002:ac8:742:: with SMTP id k2mr3542535qth.346.1556038206782;
        Tue, 23 Apr 2019 09:50:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556038206; cv=none;
        d=google.com; s=arc-20160816;
        b=dP+N/L5At84Mn6kZfIT4ZzqehI1oCCbYtWDNZKW8OVldHF08g0bZcmcpi0i7EA2L2D
         6uCrrBzDseanNe+WPJELjsoNYfSmT669PbtJAUl0fvz360E5dUX5/4GF54QpzDRWof7q
         vMSxhv1bTqA+EDKCv6Gg2Qu6fXh3Qer5f1YofCIITSd93+2AYLEMC7I5kp6v5rdjPasR
         PWOSttXAQjDoazTISXAx3yE4CrDN0dK51DuoSpEuMkt44zT9kPzMxHi1E4RrXax4Y8hb
         0U/v5/3+zWYeOJpjUNcS4IMhcWtncehbKa9Jpr3Ql/JHLNcL4uUukOBVePb40l0x6mk4
         hqbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=58QZAQnPWCJXaIZAo7dlCzisiH33M4fciKPxNT+NHWI=;
        b=ycwyk+fI8RYLe9davpv7B+3Oo8dscX6DB+ZMu0pjRq3b2EBp15K9+HFT9XYfrezHsm
         1wmEsRRXZ4pJCaXRkWibWYkBPzW5wW6uYVpUVRykWkGkU2Las3aMUL/THZtZDWBLoxS3
         8IV7w8KYkMHzalBiMMR6Hb96JX4MdUAIrDAKkwOMo9saGjV+6eAFDCizv7s+/ZlsfXTr
         sDPk2V03p0fSqUL5qGpMZ3aaBEK2BK244FQ+o67d2vow8F8QFaLeYMtELUenm4tzp2tD
         wyW1c6XVEU6YeJXRvBJI8djPo7nUO0HKDHzSy++ZdE1V1EbFi9oO7Cuu1RQ5E90Z7qjz
         nnDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Krm9mepJ;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f40sor14156561qve.60.2019.04.23.09.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 09:50:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Krm9mepJ;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=58QZAQnPWCJXaIZAo7dlCzisiH33M4fciKPxNT+NHWI=;
        b=Krm9mepJyBoMH3sCePBD6dLjNY1c2KU+7TqQnOd51+nW2XG1VslPF22clNz48VQ1Eh
         6cgs1A6O5XVBiVzQakp47QhMkv1ZpMMMFe85dzY9QEHlUso6k8EscOuUNBmIfEtEacbZ
         /US8WwNeXRddAgJguNldNlArQXT0xD/gZ75GPri3Bg5fBGLdmIyM9pean2Ivd51GwqgR
         dnIqv5rRpMVJUJ6EJQwy/CW67SFGkVaoX/pgPyEn8QZb+fMthd2j1erSWPCTrf/zpJXf
         AvlL8pghqiSX92cspUmJv9tj9C56ONCpgEbrSKUFOS3X512bs6v2kfSEg85tBtgFOH2S
         ayjw==
X-Google-Smtp-Source: APXvYqz92iGhKKjqnxiEdIsUbqTEzv+EaJ8Ir+cWEs0Z4hmROknjwVj2Slhdzjb/D6QE6zRmwwUKDMygvKBOr3W6Yl4=
X-Received: by 2002:a0c:e991:: with SMTP id z17mr11637560qvn.164.1556038206351;
 Tue, 23 Apr 2019 09:50:06 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <20190423155827.GR18914@techsingularity.net> <CALvZod7-_RgMiA-X2MdmrizWiPf3L4CtJdcbCFWiy9ZDFEc+Sw@mail.gmail.com>
In-Reply-To: <CALvZod7-_RgMiA-X2MdmrizWiPf3L4CtJdcbCFWiy9ZDFEc+Sw@mail.gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 23 Apr 2019 09:49:55 -0700
Message-ID: <CAHbLzkp1HY0+x6ug8d43rpyQZqB9-Vh_vgbVF5-pcM=3FVVsWA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, lsf-pc@lists.linux-foundation.org, 
	Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Shakeel,

This sounds interesting. Actually, we have something similar designed
in-house (called "cold" page reclaim). But, we mainly targeted to cold
page cache rather than anonymous page for the time being, and it does
in cgroup scope. We are extending it to anonymous page now.

Look forward to discussing with you.


On Tue, Apr 23, 2019 at 9:34 AM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Tue, Apr 23, 2019 at 8:58 AM Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > On Tue, Apr 23, 2019 at 08:30:46AM -0700, Shakeel Butt wrote:
> > > Though this is quite late, I still want to propose a topic for
> > > discussion during LSFMM'19 which I think will be beneficial for Linux
> > > users in general but particularly the data center users running a
> > > range of different workloads and want to reduce the memory cost.
> > >
> > > Topic: Proactive Memory Reclaim
> > >
> > > Motivation/Problem: Memory overcommit is most commonly used technique
> > > to reduce the cost of memory by large infrastructure owners. However
> > > memory overcommit can adversely impact the performance of latency
> > > sensitive applications by triggering direct memory reclaim. Direct
> > > reclaim is unpredictable and disastrous for latency sensitive
> > > applications.
> > >
> > > Solution: Proactively reclaim memory from the system to drastically
> > > reduce the occurrences of direct reclaim. Target cold memory to keep
> > > the refault rate of the applications acceptable (i.e. no impact on the
> > > performance).
> > >
> > > Challenges:
> > > 1. Tracking cold memory efficiently.
> > > 2. Lack of infrastructure to reclaim specific memory.
> > >
> > > Details: Existing "Idle Page Tracking" allows tracking cold memory on
> > > a system but it becomes prohibitively expensive as the machine size
> > > grows. Also there is no way from the user space to reclaim a specific
> > > 'cold' page. I want to present our implementation of cold memory
> > > tracking and reclaim. The aim is to make it more generally beneficial
> > > to lot more users and upstream it.
> > >
> >
> > Why is this not partially addressed by tuning vm.watermark_scale_factor?
>
> We want to have more control on exactly which memory pages to reclaim.
> The definition of cold memory can be very job specific. With kswapd,
> that is not possible.
>
> > As for a specific cold page, why not mmap the page in question,
> > msync(MS_SYNC) and call madvise(MADV_DONTNEED)? It may not be perfect in
> > all cases admittedly.
> >
>
> Wouldn't this throw away the anon memory? We want to swapout that. In
> our production we actually only target swapbacked memory due to very
> low page fault cost from zswap.
>
> Shakeel
>

