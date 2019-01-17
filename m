Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29C17C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 22:55:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5D1F20855
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 22:55:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="otOdFNZn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5D1F20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5331B8E0003; Thu, 17 Jan 2019 17:55:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E2BD8E0002; Thu, 17 Jan 2019 17:55:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9638E0003; Thu, 17 Jan 2019 17:55:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 139EA8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:55:40 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so10005640qke.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 14:55:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AN89NjtLEiQ90r1VCS8YxfBr1Y/LYwkRueepP3zw/Rs=;
        b=DaD0viIUMw1buvrzTrcIpub/BdPDau9px1QsfV9tWHAj/iv3lHhQaWC/aaOoTaT0zx
         KastVrhDgdb717x5enX3GZFem9SAypumkfREzJsoJMuj9FzKJYg8CIzFX9s0tbv+KArn
         UCGznVQ2x++5HZoxaN9SwPQNX+BZOfXZo8sJUJM2XlIEUMEwIHAhmDejXL1qCIHOMPXt
         FOlOzf+F5JaLsF6okhOnTKqW+4yQJIo5ILi/DpJGBtGkiPBSrpX/KbtmFDTZCE98EdtA
         r4559zQ9sJCoisjTu+HU7NCAqcAtSYWHAt22CB6erhDZ5Z6gkaFN8J1hbphquToAmxni
         l5yA==
X-Gm-Message-State: AJcUukc1wV79HkZoOctVTFw7A95N4JaXyipPMVDcA7kxysBjmmFQtc75
	Bwk7vBnCyug1Wlu7uzqs5RPG9ruZOx8Syegd9dWE/dGNJon7QdTZAhNWPMc+WUOTnnir6P8iyJj
	TRQdGH51c88mceF/Smo3CqdgqfBxmMbaT9bSWmRukXTOZD16nN8kDxUHALXorGLSwDvKGgqDk7g
	1GNT1/qDouFk+JiX08uLh8pJLDiTAugCsQ78q2oxUOcsfF3irxmLyJTGp0VVigPOw2UUatfj8PY
	DN82cNUrkr/4HH85wGi4hXuYjOOc/laxgeDoxsjLZyXA4soli8vb6U/tYn2FdiwbYLuzpry/R5A
	ayRbDSE6WySYpWFm40AZLC9ESV5xT8HEHWfvevE7za+ONdw110QEOhJ5Ov2jeh4B3Bme0/Nrca1
	v
X-Received: by 2002:a0c:8382:: with SMTP id k2mr13686957qva.0.1547765739731;
        Thu, 17 Jan 2019 14:55:39 -0800 (PST)
X-Received: by 2002:a0c:8382:: with SMTP id k2mr13686914qva.0.1547765738654;
        Thu, 17 Jan 2019 14:55:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547765738; cv=none;
        d=google.com; s=arc-20160816;
        b=XbFZyBqmpxsRqIlc6auxl/Sm/07fBLh7HXxitmxAucMcCvwhWQtDlAHzh4Nn0mELSY
         iGuIyG7XHYusmEZrgBNBFHpRPxqkrzdSfQ0/CeJUj6pyV3iS8dPziFmfN2f8ejCMKm4A
         Dd7z1PcS/Z8rmUK/prdDhxcYNhJwUvleevrvuKD4R1rDo7UbE7YrDm69lai4uMDT8dKx
         Gl1pG8PcuxS7/Z0xvQjbm5OySjmRruf/TgPgNGOb0yVZ3v+toHABc370d2+jkgVMipR9
         cUYk36uNixAl1bXzNzhQMScn05KJK8HFeVX9zGYFTvc1FvUQapEhvvnyvW7w3yzJCLHg
         zNUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AN89NjtLEiQ90r1VCS8YxfBr1Y/LYwkRueepP3zw/Rs=;
        b=zkh2Ne5CqgGRh0SLmkssLxd1NgdU0GTlKZBJBEQvyROryloeLEeZ3RDFb9bd1Q4TL4
         TvA1wNKuMcYuOw8a6RQk7A608/WoPVayq3g5105C1YvwREEOxgiZj0pvCMSt3he1TnrB
         fIhSdtoc2ulTRe9GeyTQMUuzpGtO0GP8k3LR1VQPUFLp1Gsku8mUlvClGi+BVJY3nDH6
         hGRCJOELW2ggrirqZkk2c70+44t0JFeU3Z+5AjeiyYzdTFrPMuKBZr2lqN0V4PMdXxM8
         RGxyQri+HE08HUco63Ld6AuN3He46FfEOGQv9geP+2Wj7Ca7Xh9kOCydzCFo0bLzLBgd
         4ZsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=otOdFNZn;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor44210221qka.72.2019.01.17.14.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 14:55:38 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=otOdFNZn;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AN89NjtLEiQ90r1VCS8YxfBr1Y/LYwkRueepP3zw/Rs=;
        b=otOdFNZnanPIBOwzuwJt3kWWMP98i+uAdV/Be38ozZztYVXbmtgiypnyN0RyrSnGR+
         FxyTX3w0a7/iW7zpi4vhotjcHDxfL9K2XmAWgX6rwF0deoIBQLB7XHWgr6qU5a5ZJ6TB
         Z4y6IXNmsDmxD+oZeGcdET9LwPUjs72Fmo1fwjwd1tDa+uU/fRyjl0JUCMrxCBGvencE
         PbL3P8+QcHaAydpa8Unr7e2TdXVOeOCD52JmA9AE/NRj6VjdqfMMpoLF8y/0gdTLn0MW
         OwoDmd7wC7r/DGw8kEjd+ihQRfq5NK/L1XC1TCiCDUk7ZNWxjR3EQwvdf5WpB3ibrhWp
         sOWA==
X-Google-Smtp-Source: ALg8bN6LQO8qvRWSecP4BQjBVk9am4bLYF/gBuo1oJT5MEuFwaUxdDOpVLSb3iXRxhTVWVG+2Cew5A6QRthmU6SVoQ4=
X-Received: by 2002:a37:d91:: with SMTP id 139mr12418208qkn.166.1547765738342;
 Thu, 17 Jan 2019 14:55:38 -0800 (PST)
MIME-Version: 1.0
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org> <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org> <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
 <20190109225143.GA22252@cmpxchg.org> <99843dad-608d-10cc-c28f-e5e63a793361@linux.alibaba.com>
 <20190114190100.GA8745@cmpxchg.org>
In-Reply-To: <20190114190100.GA8745@cmpxchg.org>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 17 Jan 2019 14:55:25 -0800
Message-ID:
 <CAHbLzko=VWTmJWkveFCw42h1v0DTswwtSucAuNAZe0iAAhbJqA@mail.gmail.com>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when offlining
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, 
	Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117225525.rHeQ_J1hc7w7D-NZNEbAUHbHS942qMMW1v9fnQWo6hk@z>

Not sure if you guys received my yesterday's reply or not. I sent
twice, but both got bounced back. Maybe my company email server has
some problems. So, I sent this with my personal email.


On Mon, Jan 14, 2019 at 11:01 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
&gt;
&gt; On Wed, Jan 09, 2019 at 05:47:41PM -0800, Yang Shi wrote:
&gt; &gt; On 1/9/19 2:51 PM, Johannes Weiner wrote:
&gt; &gt; &gt; On Wed, Jan 09, 2019 at 02:09:20PM -0800, Yang Shi wrote:
&gt; &gt; &gt; &gt; On 1/9/19 1:23 PM, Johannes Weiner wrote:
&gt; &gt; &gt; &gt; &gt; On Wed, Jan 09, 2019 at 12:36:11PM -0800,
Yang Shi wrote:
&gt; &gt; &gt; &gt; &gt; &gt; As I mentioned above, if we know some
page caches from some memcgs
&gt; &gt; &gt; &gt; &gt; &gt; are referenced one-off and unlikely
shared, why just keep them
&gt; &gt; &gt; &gt; &gt; &gt; around to increase memory pressure?
&gt; &gt; &gt; &gt; &gt; It's just not clear to me that your scenarios
are generic enough to
&gt; &gt; &gt; &gt; &gt; justify adding two interfaces that we have to
maintain forever, and
&gt; &gt; &gt; &gt; &gt; that they couldn't be solved with existing mechanisms.
&gt; &gt; &gt; &gt; &gt;
&gt; &gt; &gt; &gt; &gt; Please explain:
&gt; &gt; &gt; &gt; &gt;
&gt; &gt; &gt; &gt; &gt; - Unmapped clean page cache isn't expensive
to reclaim, certainly
&gt; &gt; &gt; &gt; &gt;     cheaper than the IO involved in new
application startup. How could
&gt; &gt; &gt; &gt; &gt;     recycling clean cache be a prohibitive
part of workload warmup?
&gt; &gt; &gt; &gt; It is nothing about recycling. Those page caches
might be referenced by
&gt; &gt; &gt; &gt; memcg just once, then nobody touch them until
memory pressure is hit. And,
&gt; &gt; &gt; &gt; they might be not accessed again at any time soon.
&gt; &gt; &gt; I meant recycling the page frames, not the cache in
them. So the new
&gt; &gt; &gt; workload as it starts up needs to take those pages from
the LRU list
&gt; &gt; &gt; instead of just the allocator freelist. While that's
obviously not the
&gt; &gt; &gt; same cost, it's not clear why the difference would be
prohibitive to
&gt; &gt; &gt; application startup especially since app startup tends
to be dominated
&gt; &gt; &gt; by things like IO to fault in executables etc.
&gt; &gt;
&gt; &gt; I'm a little bit confused here. Even though those page frames are not
&gt; &gt; reclaimed by force_empty, they would be reclaimed by kswapd later when
&gt; &gt; memory pressure is hit. For some usecases, they may prefer
get recycled
&gt; &gt; before kswapd kick them out LRU, but for some usecases avoiding memory
&gt; &gt; pressure might outpace page frame recycling.
&gt;
&gt; I understand that, but you're not providing data for the "may prefer"
&gt; part. You haven't shown that any proactive reclaim actually matters
&gt; and is a significant net improvement to a real workload in a real
&gt; hardware environment, and that the usecase is generic and widespread
&gt; enough to warrant an entirely new kernel interface.

Proactive reclaim could prevent from getting offline memcgs
accumulated. In our production environment, we saw offline memcgs
could reach over 450K (just a few hundred online memcgs) in some
cases. kswapd is supposed to help to remove offline memcgs when memory
pressure hit, but with such huge number of offline memcgs, kswapd
would take very long time to iterate all of them. Such huge number of
offline memcgs could bring in other latency problems whenever
iterating memcgs is needed, i.e. show memory.stat, direct reclaim,
oom, etc.

So, we also use force_empty to keep reasonable number of offline memcgs.

And, Fam Zheng from Bytedance noticed delayed force_empty gets things
done more effectively. Please see the discussion here
https://www.spinics.net/lists/cgroups/msg21259.html

Thanks,
Yang

</hannes@cmpxchg.org>>
> > > > > - Why you couldn't set memory.high or memory.max to 0 after the
> > > > >     application quits and before you call rmdir on the cgroup
> > > > I recall I explained this in the review email for the first version. Set
> > > > memory.high or memory.max to 0 would trigger direct reclaim which may stall
> > > > the offline of memcg. But, we have "restarting the same name job" logic in
> > > > our usecase (I'm not quite sure why they do so). Basically, it means to
> > > > create memcg with the exact same name right after the old one is deleted,
> > > > but may have different limit or other settings. The creation has to wait for
> > > > rmdir is done.
> > > This really needs a fix on your end. We cannot add new cgroup control
> > > files because you cannot handle a delayed release in the cgroupfs
> > > namespace while you're reclaiming associated memory. A simple serial
> > > number would fix this.
> > >
> > > Whether others have asked for this knob or not, these patches should
> > > come with a solid case in the cover letter and changelogs that explain
> > > why this ABI is necessary to solve a generic cgroup usecase. But it
> > > sounds to me that setting the limit to 0 once the group is empty would
> > > meet the functional requirement (use fork() if you don't want to wait)
> > > of what you are trying to do.
> >
> > Do you mean do something like the below:
> >
> > echo 0 > cg1/memory.max &
> > rmdir cg1 &
> > mkdir cg1 &
> >
> > But, the latency is still there, even though memcg creation (mkdir) can be
> > done very fast by using fork(), the latency would delay afterwards
> > operations, i.e. attaching tasks (echo PID > cg1/cgroup.procs). When we
> > calculating the time consumption of the container deployment, we would count
> > from mkdir to the job is actually launched.
>
> I'm saying that the same-name requirement is your problem, not the
> kernel's. It's not unreasonable for the kernel to say that as long as
> you want to do something with the cgroup, such as forcibly emptying
> out the left-over cache, that the group name stays in the namespace.
>
> Requiring the same exact cgroup name for another instance of the same
> job sounds like a bogus requirement. Surely you can use serial numbers
> to denote subsequent invocations of the same job and handle that from
> whatever job management software you're using:
>
>         ( echo 0 > job1345-1/memory.max; rmdir job12345-1 ) &
>         mkdir job12345-2
>
> See, completely decoupled.
>

