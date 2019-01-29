Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5193EC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:18:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 105F620857
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:18:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wU/63d3B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 105F620857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF2798E0002; Tue, 29 Jan 2019 13:18:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A77FD8E0001; Tue, 29 Jan 2019 13:18:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9400C8E0002; Tue, 29 Jan 2019 13:18:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 309F88E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:18:34 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m4so8354878wrr.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:18:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+GxBm8s8C6x84ozFyjXoCsKwNqijbNBimqTvowaT6HA=;
        b=R3cU2BuPjMNAcnhFU38ZgMTKRCkYhLzZpdQFTJWGMVGb6hZdGMRgLP4oMZhwY8vaA8
         0UgbmbuYFQ/KWL+9MtO29Ynd2CtM1LTR3PA2bEvbCEyWtsWnPq5mvXZAJxbzU+XAy2YJ
         UM9AMtBJVkiOOK/HFqr4SrbTTDPx4QXH7FlqiLR3wADDJ6k/DChhwWJLyYWX9ox5ExAO
         a8nmN5E+mHW9GsWWoB6S0XwIfeNNomQ9mnelHSja5wm60MlCml1HGU3Pihem7RvtJ6Sn
         P7QI/q68IQct/TAg0p29P6zJy04Fh0+J8GTNKZsitZ5Ob8pH0rAe1dx8vTuGGWMlb2mM
         QSdA==
X-Gm-Message-State: AJcUukfHE2gBAK1aya7SC7cIjgPjiL4uKkmCeAMBNpnkFNZOrs6GMBx4
	4Xf0j1mFbWe5vekfOcbQz2EfMl4X+vOUcEwLfOgdAk4+wOWAFAvT0xwNoS5R8hgV7uKQxLjmd98
	VoRe+xhfscsjAPqPOgrUESf+tbgpEqbe+mjZmagY1sF85nHlhkA5dYRJECp+jAyrtHZPupPeeTl
	+W9GkdagNdbhz57CbRBjbU3bA8spHV3D+zJ/ne3TdX6Fe4/1XhgzevFWFZ1iiiPH31l3yDpWUuE
	mL2HE1LO0bpEQIGICobAaVVNxvPeXEhpov4XHY5otUHWR6ZUh8au5xpxPy75Fjldx9yOCctt0lc
	7k9kDUT/uP3qnnCusAEB8ViThf7xsbMr9Uanr/zt+yRDdanpDSO6odKg6nc5ibGeWcr1Hy0sQTE
	V
X-Received: by 2002:a1c:f207:: with SMTP id s7mr21728676wmc.87.1548785913598;
        Tue, 29 Jan 2019 10:18:33 -0800 (PST)
X-Received: by 2002:a1c:f207:: with SMTP id s7mr21728623wmc.87.1548785912367;
        Tue, 29 Jan 2019 10:18:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548785912; cv=none;
        d=google.com; s=arc-20160816;
        b=wcZL4s4cVC1aHHUPjJwE0lZQQdMSqmvC460n7PcSylp8n3LkjVoQ6NekG52Bg0TGVA
         12/xEeJekW83NE0jAvpxCJLHAT4MNbPqS/NTTkV8iMuv69rDa1/7jWY1/+iJZRo2nXqb
         GgM2nBgUxjnjvUzVxAs9cF78I/eurxJ5vlYpQ1qmlZ9RXMxaQlU66y+/2Ydj/iHbHu/w
         xBC6Zie9empaEAPYZG5lZHEetyirgzq9P3YjveOJpTGEQ1SxPuXrm3i4nBqlDKQdKOnw
         k7RNMBkxtcKwxgNafPWK2NLjBeSmezp8jy84zdM1TmUPMFfnN9YjYUnbFXmFWqFwI0Pm
         Y8Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+GxBm8s8C6x84ozFyjXoCsKwNqijbNBimqTvowaT6HA=;
        b=F98NGKZpxH3t6s7mn2l44IyDvE34FE+GHKEcvShznxRPM4Z7wB7+AUPPCPmGodBpZx
         9pkLk0Z9H3x0OsPG3Yh2upH9qqVN/vX/O0UzmKW0J2V9/6qvdIb//gb78hzdM7zoINjL
         1pHXYLN8O7edtGovllpe3vOqc7Pt5lDlBm54uLF0YBFf5WxfnPRxZv52As9XOBQtLBAq
         4UG/AwobAYSWaW8IfomlFiakfdMjpqtUTy0VC7DiPZPAIwJy2h6FcA8RceH4kdCC8bbL
         o7uUAhet7en2aQHLNz/lJsjQXsmL0LQFnf91y5enDgSTvWXwDYUi35osE73vm5Lf8IYa
         cnIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="wU/63d3B";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor60714808wrx.39.2019.01.29.10.18.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:18:32 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="wU/63d3B";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+GxBm8s8C6x84ozFyjXoCsKwNqijbNBimqTvowaT6HA=;
        b=wU/63d3BqpbaETl1R60YuKHDVlM6oWOlycD365weCHPw8D4pDzyh2VmzYqavACHnQy
         2E0vBCvdlWBdD0etwek0HhdNqKvPtKLOAlQFgRzID0mB2cjaCZJAIigmbf1v4lWqUmwF
         JYp4Lm4pJN4DP1NeOojB4yAKbERZnHYyTY/xV0SnPKvVMxwa0YihtVntVY4dx1P0s7Xv
         4qCpYp2b+meS9qpg6uaMXpF6iwtg2kmE0QFWzaul4ag1gf7tCHOCDFeIDiSALdVR1tN1
         YAYiKWKxmIsV+dTX2MeLcYGkNN7xNy2V9BjAvc+Yg3lghhd8r0GW1PvEMaDY7CwEZJHL
         Tr5A==
X-Google-Smtp-Source: ALg8bN4cRFK+VVM41OOXWUgll/3WKZxT3SdKfFLzYyHoHPggY6R004Qc5iemMNf5Igp61Tl5EGthoyMNhU9XqAws9iQ=
X-Received: by 2002:a5d:4e82:: with SMTP id e2mr26340980wru.291.1548785911774;
 Tue, 29 Jan 2019 10:18:31 -0800 (PST)
MIME-Version: 1.0
References: <20190124211518.244221-1-surenb@google.com> <20190124211518.244221-6-surenb@google.com>
 <20190129123843.GK28467@hirez.programming.kicks-ass.net>
In-Reply-To: <20190129123843.GK28467@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 29 Jan 2019 10:18:20 -0800
Message-ID: <CAJuCfpGxtGHsow002nd8Ao8mo9MaZQqZau_NLTMrZ8=aypTkig@mail.gmail.com>
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

On Tue, Jan 29, 2019 at 4:38 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > +                     atomic_set(&group->polling, polling);
> > +                     /*
> > +                      * Memory barrier is needed to order group->polling
> > +                      * write before times[] read in collect_percpu_times()
> > +                      */
> > +                     smp_mb__after_atomic();
>
> That's broken, smp_mb__{before,after}_atomic() can only be used on
> atomic RmW operations, something atomic_set() is _not_.

Oh, I didn't realize that. After reading the following example from
atomic_ops.txt I was under impression that smp_mb__after_atomic()
would make changes done by atomic_set() visible:

/* All memory operations before this call will
* be globally visible before the clear_bit().
*/
smp_mb__before_atomic();
clear_bit( ... );
/* The clear_bit() will be visible before all
* subsequent memory operations.
*/
smp_mb__after_atomic();

but I'm probably missing something. Is there a more detailed
description of these rules anywhere else?

Meanwhile I'll change smp_mb__after_atomic() into smp_mb(). Would that
fix the ordering?

> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

