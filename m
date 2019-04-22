Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4BDAC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:34:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D50C20685
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ilDw+5r8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D50C20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A637D6B0003; Mon, 22 Apr 2019 10:34:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE1B6B0006; Mon, 22 Apr 2019 10:34:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DA996B0007; Mon, 22 Apr 2019 10:34:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD666B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 10:34:47 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id z25so1845840ljb.13
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 07:34:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iCzVp5vF6iDBAI+czbURXbmPXOxg0PnfhL4c6EOuwEI=;
        b=soPoT7AeYABKFi7MYMKwTrvVhQqIs4k4u3RFluQt+dJSsMhC3jNUeZyRgxDLyFNrEZ
         APjcXtU42ml548fsVK/E3Bhb0LeeSn5DQW9yDFlZGIoFx6K6dYtbdcEwl/z8BNKpfWYp
         7IVflmfDeSH0iG1M7JFtra89iMR82qkDVtPFAPkZvwczEfs5VPgqUOty0EhzXm30uFqj
         YYJMy+qXUUF7HxxoxmMFHBxNN/FYfHJ6dmL6G7+NNHFYPaqbbyB6u1eaAvbgVcqO7uYa
         JopdRE6RyCXyddKKqCamgzcKOBBJksxwcOq8VBcd+KtWnVpDMdST6EPFL8JQ3rrBj50l
         vElg==
X-Gm-Message-State: APjAAAWqIhUUSWtLtUccFlJB05Aoo+1auHNI73F1Hgd2YbBtUwizRoTK
	rOnVdqwTTh9IYUKIQriBnKKMzANz2PBbSgoIa3zDKmbOEwtJB0jc5CAUBspEbZ6DkoHSl14XHCm
	h25COf/jPa5TYfJqRT8sRp6tG9D6xl8+mgJhEU/Gfp5gX1RuFUINspeXHrH2M7E635Q==
X-Received: by 2002:ac2:5326:: with SMTP id f6mr10328363lfh.100.1555943686094;
        Mon, 22 Apr 2019 07:34:46 -0700 (PDT)
X-Received: by 2002:ac2:5326:: with SMTP id f6mr10328323lfh.100.1555943685053;
        Mon, 22 Apr 2019 07:34:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555943685; cv=none;
        d=google.com; s=arc-20160816;
        b=wAdjwQNpKRWtPxbu9V5btKyVAD8LqcJAYlARIhGMBbkl3s0CPBTDAE3tNaDVrTrSGl
         7ouycjMhyO4Kxii2LXMMfQNurjfFEf3GbcCc7xIKQ8mHAbtnuVxoDNdTupsHTF1jAA5Z
         l6Me03p2h1gpsquGAXQNq1iTD66zeafMiOvdqI7CWXG98XWjPJW5pYLABK+hzSsG7C/A
         hONLdigArhVjPb5NF8a6uOhP43EUh9JQZHBLhDrn0MhPPuhMayIA+mUSOqtkuScjWEZ8
         8Czm0KiiFTyOVUPFb7dBXvK8xZuXOA/FbxPoyLic2IKPzeNf9WGgiUkkA8ByEvzudLKg
         ljAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iCzVp5vF6iDBAI+czbURXbmPXOxg0PnfhL4c6EOuwEI=;
        b=On18ucac8xy/KW32Zvs2s9vBOEufNyMvC3WOFsuxnr8MPaPYbsE7iIwEZviUhSrz2x
         W4YounfCC1rwzd9yiKUiTFcm7niBCvS6o7gMmFCn1k8CgnnjpsEsDzjzabgLxbE0N29F
         S82a4uAG0MKcVcLZvrr/7bMNkyLqQ+oDzVrNz5I4pkiaghXpWC+1/rvQNRrljnCaNjNT
         fvBH3PlQr/TYANXbBBToYFMgQGLEWV4i1+TDtYsw1ue+wZQajL6KIqTKKd1QQGRi7RH+
         fGvkwldQIvBhgeFt3rGHd+mWPKaFSXouSHaTG01/+EeaZdNfycZIRJ6jjKvuozi5iGE8
         GjRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ilDw+5r8;
       spf=pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ufo19890607@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor5678299ljg.8.2019.04.22.07.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Apr 2019 07:34:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ilDw+5r8;
       spf=pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ufo19890607@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iCzVp5vF6iDBAI+czbURXbmPXOxg0PnfhL4c6EOuwEI=;
        b=ilDw+5r8d4iCFLlT5FNl76PbARnX9BPLX5F4ZBJfiixMUCuvxn+tYoRPiINz54TKFO
         gxzlHzzNWOf+2UO1uHlBM1hy1PDvepUyVNoUuHgvg4gIQYy2J8tfNjD25DyQ7aQ1MvR1
         B3b38muIdazxJJ+32Zc0i+dE5B+RGMTgaRD0qwUZHFmBIzRn8rY14Uf93ZCh7QIqxMkx
         yg+wIfLa5DRn7M8SpkgA7ikR94xDB2LA8rFf1xYU44VhWlxzStqxHIiTVS867yWcX7Zd
         vlOslk7vT//ncvKn+UZeK8wKnyjZKzDFR73g7C0eU5HC/X7ZkZ1pgpagI8OFLqW72HdA
         c1Mw==
X-Google-Smtp-Source: APXvYqyKT0FiSGQFRhj/U1fFJugTjJQOmqGcQpOj/0C04yyIc7TWVcfQmI/79hOdyGPBgYYsglC960GAwzIBbJhsLgU=
X-Received: by 2002:a2e:7007:: with SMTP id l7mr10347864ljc.101.1555943684642;
 Mon, 22 Apr 2019 07:34:44 -0700 (PDT)
MIME-Version: 1.0
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
In-Reply-To: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 22 Apr 2019 22:34:32 +0800
Message-ID: <CAHCio2gEw4xyuoiurvwzvEiU8eLas+5ZLhzmqm1V2CJqvt+cyA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] NUMA Balancer Suite
To: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org, mhocko@kernel.org, 
	vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="0000000000009d1d3b05871f5efc"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000009d1d3b05871f5efc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi, Michael
I really want to know how could you fix the conflict between numa balancer
and load balancer. Maybe you gained numa bonus by migrating some tasks to
the node with most of the cache there, but, cpu load balance was break, so
how to do it ?

Thanks
Wind


=E7=8E=8B=E8=B4=87 <yun.wang@linux.alibaba.com> =E4=BA=8E2019=E5=B9=B44=E6=
=9C=8822=E6=97=A5=E5=91=A8=E4=B8=80 =E4=B8=8A=E5=8D=8810:13=E5=86=99=E9=81=
=93=EF=BC=9A

> We have NUMA Balancing feature which always trying to move pages
> of a task to the node it executed more, while still got issues:
>
> * page cache can't be handled
> * no cgroup level balancing
>
> Suppose we have a box with 4 cpu, two cgroup A & B each running 4 tasks,
> below scenery could be easily observed:
>
> NODE0                   |       NODE1
>                         |
> CPU0            CPU1    |       CPU2            CPU3
> task_A0         task_A1 |       task_A2         task_A3
> task_B0         task_B1 |       task_B2         task_B3
>
> and usually with the equal memory consumption on each node, when tasks ha=
ve
> similar behavior.
>
> In this case numa balancing try to move pages of task_A0,1 & task_B0,1 to
> node 0,
> pages of task_A2,3 & task_B2,3 to node 1, but page cache will be located
> randomly,
> depends on the first read/write CPU location.
>
> Let's suppose another scenery:
>
> NODE0                   |       NODE1
>                         |
> CPU0            CPU1    |       CPU2            CPU3
> task_A0         task_A1 |       task_B0         task_B1
> task_A2         task_A3 |       task_B2         task_B3
>
> By switching the cpu & memory resources of task_A0,1 and task_B0,1, now
> workloads
> of cgroup A all on node 0, and cgroup B all on node 1, resource
> consumption are same
> but related tasks could share a closer cpu cache, while cache still
> randomly located.
>
> Now what if the workloads generate lot's of page cache, and most of the
> memory
> accessing are page cache writing?
>
> A page cache generated by task_A0 on NODE1 won't follow it to NODE0, but
> if task_A0
> was already on NODE0 before it read/write files, caches will be there, so
> how to
> make sure this happen?
>
> Usually we could solve this problem by binding workloads on a single node=
,
> if the
> cgroup A was binding to CPU0,1, then all the caches it generated will be
> on NODE0,
> the numa bonus will be maximum.
>
> However, this require a very well administration on specified workloads,
> suppose in our
> cases if A & B are with a changing CPU requirement from 0% to 400%, then
> binding to a
> single node would be a bad idea.
>
> So what we need is a way to detect memory topology on cgroup level, and
> try to migrate
> cpu/mem resources to the node with most of the caches there, as long as
> the resource
> is plenty on that node.
>
> This patch set introduced:
>   * advanced per-cgroup numa statistic
>   * numa preferred node feature
>   * Numa Balancer module
>
> Which helps to achieve an easy and flexible numa resource assignment, to
> gain numa bonus
> as much as possible.
>
> Michael Wang (5):
>   numa: introduce per-cgroup numa balancing locality statistic
>   numa: append per-node execution info in memory.numa_stat
>   numa: introduce per-cgroup preferred numa node
>   numa: introduce numa balancer infrastructure
>   numa: numa balancer
>
>  drivers/Makefile             |   1 +
>  drivers/numa/Makefile        |   1 +
>  drivers/numa/numa_balancer.c | 715
> +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/memcontrol.h   |  99 ++++++
>  include/linux/sched.h        |   9 +-
>  kernel/sched/debug.c         |   8 +
>  kernel/sched/fair.c          |  41 +++
>  mm/huge_memory.c             |   7 +-
>  mm/memcontrol.c              | 246 +++++++++++++++
>  mm/memory.c                  |   9 +-
>  mm/mempolicy.c               |   4 +
>  11 files changed, 1133 insertions(+), 7 deletions(-)
>  create mode 100644 drivers/numa/Makefile
>  create mode 100644 drivers/numa/numa_balancer.c
>
> --
> 2.14.4.44.g2045bb6
>
>

--0000000000009d1d3b05871f5efc
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi, Michael<div>I really want to know how could you fix th=
e conflict between numa balancer and load balancer. Maybe you gained numa b=
onus by migrating some tasks to the node with most of the cache there, but,=
 cpu load balance was break, so how to do it ?</div><div><br></div><div>Tha=
nks</div><div>Wind</div></div><br><br><div class=3D"gmail_quote"><div dir=
=3D"ltr" class=3D"gmail_attr">=E7=8E=8B=E8=B4=87 &lt;<a href=3D"mailto:yun.=
wang@linux.alibaba.com">yun.wang@linux.alibaba.com</a>&gt; =E4=BA=8E2019=E5=
=B9=B44=E6=9C=8822=E6=97=A5=E5=91=A8=E4=B8=80 =E4=B8=8A=E5=8D=8810:13=E5=86=
=99=E9=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left=
:1ex">We have NUMA Balancing feature which always trying to move pages<br>
of a task to the node it executed more, while still got issues:<br>
<br>
* page cache can&#39;t be handled<br>
* no cgroup level balancing<br>
<br>
Suppose we have a box with 4 cpu, two cgroup A &amp; B each running 4 tasks=
,<br>
below scenery could be easily observed:<br>
<br>
NODE0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 =C2=A0 =C2=A0NODE1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 |<br>
CPU0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU1=C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 =C2=A0 =C2=A0CPU2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU3<br>
task_A0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_A1 |=C2=A0 =C2=A0 =C2=A0 =C2=
=A0task_A2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_A3<br>
task_B0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_B1 |=C2=A0 =C2=A0 =C2=A0 =C2=
=A0task_B2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_B3<br>
<br>
and usually with the equal memory consumption on each node, when tasks have=
<br>
similar behavior.<br>
<br>
In this case numa balancing try to move pages of task_A0,1 &amp; task_B0,1 =
to node 0,<br>
pages of task_A2,3 &amp; task_B2,3 to node 1, but page cache will be locate=
d randomly,<br>
depends on the first read/write CPU location.<br>
<br>
Let&#39;s suppose another scenery:<br>
<br>
NODE0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 =C2=A0 =C2=A0NODE1<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 |<br>
CPU0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU1=C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 =C2=A0 =C2=A0CPU2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU3<br>
task_A0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_A1 |=C2=A0 =C2=A0 =C2=A0 =C2=
=A0task_B0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_B1<br>
task_A2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_A3 |=C2=A0 =C2=A0 =C2=A0 =C2=
=A0task_B2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_B3<br>
<br>
By switching the cpu &amp; memory resources of task_A0,1 and task_B0,1, now=
 workloads<br>
of cgroup A all on node 0, and cgroup B all on node 1, resource consumption=
 are same<br>
but related tasks could share a closer cpu cache, while cache still randoml=
y located.<br>
<br>
Now what if the workloads generate lot&#39;s of page cache, and most of the=
 memory<br>
accessing are page cache writing?<br>
<br>
A page cache generated by task_A0 on NODE1 won&#39;t follow it to NODE0, bu=
t if task_A0<br>
was already on NODE0 before it read/write files, caches will be there, so h=
ow to<br>
make sure this happen?<br>
<br>
Usually we could solve this problem by binding workloads on a single node, =
if the<br>
cgroup A was binding to CPU0,1, then all the caches it generated will be on=
 NODE0,<br>
the numa bonus will be maximum.<br>
<br>
However, this require a very well administration on specified workloads, su=
ppose in our<br>
cases if A &amp; B are with a changing CPU requirement from 0% to 400%, the=
n binding to a<br>
single node would be a bad idea.<br>
<br>
So what we need is a way to detect memory topology on cgroup level, and try=
 to migrate<br>
cpu/mem resources to the node with most of the caches there, as long as the=
 resource<br>
is plenty on that node.<br>
<br>
This patch set introduced:<br>
=C2=A0 * advanced per-cgroup numa statistic<br>
=C2=A0 * numa preferred node feature<br>
=C2=A0 * Numa Balancer module<br>
<br>
Which helps to achieve an easy and flexible numa resource assignment, to ga=
in numa bonus<br>
as much as possible.<br>
<br>
Michael Wang (5):<br>
=C2=A0 numa: introduce per-cgroup numa balancing locality statistic<br>
=C2=A0 numa: append per-node execution info in memory.numa_stat<br>
=C2=A0 numa: introduce per-cgroup preferred numa node<br>
=C2=A0 numa: introduce numa balancer infrastructure<br>
=C2=A0 numa: numa balancer<br>
<br>
=C2=A0drivers/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 =C2=A01 +<br>
=C2=A0drivers/numa/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A01 +<br=
>
=C2=A0drivers/numa/numa_balancer.c | 715 ++++++++++++++++++++++++++++++++++=
+++++++++<br>
=C2=A0include/linux/memcontrol.h=C2=A0 =C2=A0|=C2=A0 99 ++++++<br>
=C2=A0include/linux/sched.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A09 +-<b=
r>
=C2=A0kernel/sched/debug.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A08=
 +<br>
=C2=A0kernel/sched/fair.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 41 +++<=
br>
=C2=A0mm/huge_memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 =C2=A07 +-<br>
=C2=A0mm/memcontrol.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 246=
 +++++++++++++++<br>
=C2=A0mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |=C2=A0 =C2=A09 +-<br>
=C2=A0mm/mempolicy.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
|=C2=A0 =C2=A04 +<br>
=C2=A011 files changed, 1133 insertions(+), 7 deletions(-)<br>
=C2=A0create mode 100644 drivers/numa/Makefile<br>
=C2=A0create mode 100644 drivers/numa/numa_balancer.c<br>
<br>
-- <br>
2.14.4.44.g2045bb6<br>
<br>
</blockquote></div>

--0000000000009d1d3b05871f5efc--

