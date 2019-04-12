Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0866DC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:38:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD1792082E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:38:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vjhFS4fO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD1792082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BFF56B0271; Fri, 12 Apr 2019 16:38:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36E576B0272; Fri, 12 Apr 2019 16:38:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25D1B6B0273; Fri, 12 Apr 2019 16:38:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 081D96B0271
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:38:20 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id p73so7877727ywp.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WOEqioenipxbzm+7k35/3dZl524W3sMRWwsLbeTAQhk=;
        b=RFLLI2JF3y0slHBHkSMAdo3qpdarPXNY6yK0lPsw48xDv3eOI+rQgBm4sOyZrxFyo7
         MYevlzghMIHnk9Qu8XAiNtklmo96CVHwND7C7m7u4ZB8I9y99fsC9/EHG2K5mshVXjVp
         dJCvvG84uL7/+pIpG+m1wxXk8rE65c3wpHGXmHbzqAhq+Jqit2cLaUmkbfYLF0J9mDV4
         u2+LtyPVfclCz3XYKcMTvoeK1DUX3tLKObEvFJbqDkvb3V8F8XT5Fjz/gFWcKYLV9uUf
         RG6QsDLOCeQqfI/LbPRry7DpC7a2p6xIABYxHG1LToyRkECWNc8jG0NCCRUz7MB70tnI
         sNug==
X-Gm-Message-State: APjAAAVZ55/ZyUhv8InDlAhZWqd45DntApHAIscc3CAkHnbJcZEY2vUz
	XhrnzvFTR/qYL0OHbNAR1tqvlstufbivowPd5+F0pK56QoJ8cFnN9yBQGKeUBDlCfNJTalpBX1T
	cYDnIT82YzOuV26euTeDOUJqXB9c8WvRaeD9nSQh4QlaSAFi2efWV6Xm47J9MAxSjcA==
X-Received: by 2002:a25:cb0d:: with SMTP id b13mr40549704ybg.296.1555101499728;
        Fri, 12 Apr 2019 13:38:19 -0700 (PDT)
X-Received: by 2002:a25:cb0d:: with SMTP id b13mr40549664ybg.296.1555101498972;
        Fri, 12 Apr 2019 13:38:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555101498; cv=none;
        d=google.com; s=arc-20160816;
        b=rT2M7dcqLDKpbxp4/48pTj+klUCRt/9INDNGFogXYYukH6ZnRU7ppfedcm7Jk55lIw
         Ih28ufHkjOvWRdMXXdlZN57MaV4VJYvT3qp64z1MZeCAAiqyrfFHD7CO86n91MEevV7r
         NLlfNMNkTE+dO31kOrAXOmmC7ghZrMi4uPgNt9ZAqTLrMKjssSTOneGbo4R89FrZ9Ds4
         6z3X+Kum5i4DG6VJ1Ej7bmBZ1LH5FLll54KI/eTDCWZdZIslhmX4d/+Uysdy8TMcH7gN
         kcpzssFvjlqfYBo8RmMoscVmp570BoP49br+RegoqUPkQZYJ9H+fHvV6FeYtdfkq/Elj
         7E9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WOEqioenipxbzm+7k35/3dZl524W3sMRWwsLbeTAQhk=;
        b=OTpd1rZEgIeS3ymd8yv0S0f5dUoNjmwiwWlbZAWeqCkt6VU3WEJMaIZ3Qb/oICIwGI
         YqU2Y/oOenvjKE9mV8k56d3wdf8KuSHNCtTCLP3lyG85RvWTa9iYuG7rdg3qaEDWpYWb
         68If8rXJG2WjzbLb0Mbw1CVbd802ELCO+LmU2eQWWadvFEo7RLrmW9tVfzZ4QGxrq8Gp
         EHZ62LKZXGInaZGjQ4J/5AM3YyIO98W5JyG8MjXlEKq9w6GJw3kM6NbWchZusxW6/y0R
         4/2B5jr+EdBCvp7UhLdmkroV43K6AcaXC1FU1jVRkXlBL+lWFn+O6y711WfiJ/WanAA0
         xAVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vjhFS4fO;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o15sor1182518ybk.85.2019.04.12.13.38.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 13:38:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vjhFS4fO;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WOEqioenipxbzm+7k35/3dZl524W3sMRWwsLbeTAQhk=;
        b=vjhFS4fOxo2Fj0LqIMr1LXlEtE5hGVVS4kg+kni9d0nYGWqXbVHBHSHDIq6HjqHVfK
         6/CW+MALCvXA2OOeNtACh91JZ2d7/8n7Nmk05bGR15WV91PMf6W15BncEgCrcgoFF8QN
         O7fLLfSLR0wLz07gnsUNyjy0216a+mO11nLfQxSY6N6pNAJaXHen01o7PZzJF0yPz/Nk
         QVfTDGoL7y78XALI4X+1XaMzIF7naI/6arE9XqfIOC4GxkYQncqS/CBoVSnnFuCdD78D
         iMGEN3gMLjo5XKLB91tkWEP9ATedoWxAYvi1q/zTbTQZt/BqpSFRYue4qJwPLPzU1/9Y
         /jiw==
X-Google-Smtp-Source: APXvYqy+H/DZ9V/1mu3nzhtyatvdYzr5K8UG3C4Ui1ihmpMBioYFZTrR+jGYV79BtYfg5f5/InhfgEWMYS5UBCj/QWI=
X-Received: by 2002:a25:1e57:: with SMTP id e84mr48719412ybe.184.1555101498296;
 Fri, 12 Apr 2019 13:38:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190412151507.2769-1-hannes@cmpxchg.org> <20190412151507.2769-4-hannes@cmpxchg.org>
 <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com> <20190412201004.GA27187@cmpxchg.org>
In-Reply-To: <20190412201004.GA27187@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 12 Apr 2019 13:38:07 -0700
Message-ID: <CALvZod6uw0auc_j+QWC-QBEGwLemtG=uUaf2dxwgbZUkOq6=1A@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team@fb.com, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 1:10 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Fri, Apr 12, 2019 at 12:55:10PM -0700, Shakeel Butt wrote:
> > We also faced this exact same issue as well and had the similar solution.
> >
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
>
> Thanks for the review!
>
> > (Unrelated to this patchset) I think there should also a way to get
> > the exact memcg stats. As the machines are getting bigger (more cpus
> > and larger basic page size) the accuracy of stats are getting worse.
> > Internally we have an additional interface memory.stat_exact for that.
> > However I am not sure in the upstream kernel will an additional
> > interface is better or something like /proc/sys/vm/stat_refresh which
> > sync all per-cpu stats.
>
> I was talking to Roman about this earlier as well and he mentioned it
> would be nice to have periodic flushing of the per-cpu caches. The
> global vmstat has something similar. We might be able to hook into
> those workers, but it would likely require some smarts so we don't
> walk the entire cgroup tree every couple of seconds.
>
> We haven't had any actual problems with the per-cpu fuzziness, mainly
> because the cgroups of interest also grow in size as the machines get
> bigger, and so the relative error doesn't increase.
>

Yes, this is very machine size dependent. We see this issue more often
on larger machines.

> Are your requirements that the error dissipates over time (waiting for
> a threshold convergence somewhere?) or do you have automation that
> gets decisions wrong due to the error at any given point in time?

Not sure about the first one but we do have the second case. The node
controller does make decisions in an online way based on the stats.
Also we do periodically collect and store stats for all jobs across
the fleet. This data is processed (offline) and is used in a lot of
ways. The inaccuracy in the stats do affect all that analysis
particularly for small jobs.

