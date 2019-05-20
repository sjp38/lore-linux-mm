Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3A40C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:00:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99455216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:00:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="splOX657"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99455216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 337126B0003; Mon, 20 May 2019 13:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E76B6B0005; Mon, 20 May 2019 13:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D6606B0006; Mon, 20 May 2019 13:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2EE06B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:00:05 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id m188so78555ita.0
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=a9HxCz0foDNs5O3pbgandNCjjTka/BKF7J0X9z8Vxf4=;
        b=kIk1JDtItydPyerqVN8BYwKHul1UNfsbAxZDHSuvcxd0ryxM5YxIKZpatCKBFgAVLy
         i0dY0BfTb5SxnJHTt5R5Al+ggqc/VEgJ97uyKeDqKdRyrVhUV4RiTdbnz8zITA0dVEOm
         7GdYBidVvdjuQJUsEN59sX+57ybSLSvW8S6aP5gt8qkxw3av3BHvfGFFVnN+fcRaB95C
         fkmPTS9ZFAePaEi8SVr5u2anR6+nUlb3gOoDH5ekaIjjw2XdTxmDhsc9LjTWeCwgSzyh
         fNqyOGkZw9Ev8rKReh7UifIjHuyIx3urjOHLH1SJ+DuUlQ6voN65rE3Tfw2QSJ4HBEaz
         vBUg==
X-Gm-Message-State: APjAAAWEl5gvvLcns83wna3FW5xnXyjP9HhO84SIfyhSzlhuraDpF8GM
	u5ZZAAsgzmcSyy1GEoDWwJqcar0SKwbaoaIz8oh3EB8fTrgeFdQ4m2xJZfR6D/uUxaT6Jbq5leQ
	5W+JUq41mPBYsMrSJvg0ufQx+HNV0qDeZT+2FuFm4WdcAyxSfYR/LNixm5fDNSrkKXg==
X-Received: by 2002:a24:b048:: with SMTP id b8mr11308itj.115.1558371605675;
        Mon, 20 May 2019 10:00:05 -0700 (PDT)
X-Received: by 2002:a24:b048:: with SMTP id b8mr11260itj.115.1558371604868;
        Mon, 20 May 2019 10:00:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558371604; cv=none;
        d=google.com; s=arc-20160816;
        b=XtuLRuNPUUtNbJhKt0QN/htp1nSZkWQT/dRlhYW1uhg0aFYFQSuDZElA5cnQoNeHuf
         fV4Ibkd652ryFWkFIZh9yeBq0p7kw3FpJGWSE31R8BfVcxbXuoWizPRNMqbiQqua8QAJ
         UgwbTdHAc4J+xSI/EZ8/ckVKf4+boxG1Yyh/dAchhZDvb+1bil7Yeb4gpjLQKN4M8d5q
         +zbLXnOf2kt8eKnerDZF9bQrwlY+FQeWCGH3LWfC40KPQMN8gAts5EcKIXek3qpCPeoS
         +laVw3G+d1c9f2ixpunzUA8MTEHJiw4829lZ8CoVs2p2PKaNnhtfgt1sM9ydOoR3/tEd
         nwcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=a9HxCz0foDNs5O3pbgandNCjjTka/BKF7J0X9z8Vxf4=;
        b=hJB2gstaDuGvoZTjFNyHVNmnUKKX4CwNJKx6Mchaz4dAZjKGrmBL74KXbow8BpZAtg
         57JtE6WjKmoFnyPNBCnN45Ylt1V9xaxsFsa3ERbQsRMT+6c43Lf/kMw/1p66A+UCisRc
         hgDAtwv+ea5LYnd+lKU+f2w3PzngIU1ni1qW8j6u3FTMe7zEPFt42HC8OBk0FQ/pLYVg
         QgDJ2Fur2GCJjOBYc1SAUrfDuiiCjhur/Yg37Tpz0NT+JlD3L5bNVEeUuZehHtCiF0iN
         P+7Ul/sKX7uADpNKWWYRUfNVeYPQa7Uz7NHRcfB27QPrth4KgNXlcScneQ2h8xo/UsQ2
         kqQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=splOX657;
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 186sor64348ita.36.2019.05.20.10.00.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:00:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=splOX657;
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=a9HxCz0foDNs5O3pbgandNCjjTka/BKF7J0X9z8Vxf4=;
        b=splOX6579zCxu8w2x60dHrYaM+Xypz557w+QNlIAc5+jHrsya6YGpJe0FdAFDMLXLp
         s+PuQebm04NIf42o+d8/JT/s3fnZodHBtyot2dQR/eVP7Hs5DzLXOxtnMZM+mdx5aZt0
         U3/7AiokG+Pwo1P2b9icTB+0Xm0xOwSlPOdow59cuJUueC/13byLOut2FSxdKv1bSEAf
         mQi/TNTuOlUe2OGWsmzYyoUUeYcd8CzRIClsW2nEje4eZnxNG6qGl6OPxvfI3R4s19sV
         0eu9DUzq6niepxI7SSdVhMNyQeq2S1Ri2DtHk7VDpYokgeMQdPAiY2vb1TYVjQyzf4CX
         ng/g==
X-Google-Smtp-Source: APXvYqxcTQzgFbWL33MuIA08BQG6r4172rHpmkGhiZLa8jGMztN1c0YHSZispXFJVvLlv+unuZuWPF77PfLiwhvwKs8=
X-Received: by 2002:a24:c904:: with SMTP id h4mr53623itg.46.1558371604283;
 Mon, 20 May 2019 10:00:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
In-Reply-To: <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
From: Tim Murray <timmurray@google.com>
Date: Mon, 20 May 2019 09:59:52 -0700
Message-ID: <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Daniel Colascione <dancol@google.com>, Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> Or Is the objective here is reduce the number of processes which get killed by
> lmkd by triggering swapping for the unused memory (user hinted) sooner so that
> they dont get picked by lmkd. Under utilization for zram hardware is a concern
> here as well ?

The objective is to avoid some instances of memory pressure by
proactively swapping pages that userspace knows to be cold before
those pages reach the end of the LRUs, which in turn can prevent some
apps from being killed by lmk/lmkd. As soon as Android userspace knows
that an application is not being used and is only resident to improve
performance if the user returns to that app, we can kick off
process_madvise on that process's pages (or some portion of those
pages) in a power-efficient way to reduce memory pressure long before
the system hits the free page watermark. This allows the system more
time to put pages into zram versus waiting for the watermark to
trigger kswapd, which decreases the likelihood that later memory
allocations will cause enough pressure to trigger a kill of one of
these apps.

> Swapping out memory into zram wont increase the latency for a hot start ? Or
> is it because as it will prevent a fresh cold start which anyway will be slower
> than a slow hot start. Just being curious.

First, not all swapped pages will be reloaded immediately once an app
is resumed. We've found that an app's working set post-process_madvise
is significantly smaller than what an app allocates when it first
launches (see the delta between pswpin and pswpout in Minchan's
results). Presumably because of this, faulting to fetch from zram does
not seem to introduce a noticeable hot start penalty, not does it
cause an increase in performance problems later in the app's
lifecycle. I've measured with and without process_madvise, and the
differences are within our noise bounds. Second, because we're not
preemptively evicting file pages and only making them more likely to
be evicted when there's already memory pressure, we avoid the case
where we process_madvise an app then immediately return to the app and
reload all file pages in the working set even though there was no
intervening memory pressure. Our initial version of this work evicted
file pages preemptively and did cause a noticeable slowdown (~15%) for
that case; this patch set avoids that slowdown. Finally, the benefit
from avoiding cold starts is huge. The performance improvement from
having a hot start instead of a cold start ranges from 3x for very
small apps to 50x+ for larger apps like high-fidelity games.

