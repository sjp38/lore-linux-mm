Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8B8AC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:42:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A3BD2070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:42:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qxWwskZ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A3BD2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 301FB8E0003; Mon, 29 Jul 2019 01:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B32B8E0002; Mon, 29 Jul 2019 01:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A2BC8E0003; Mon, 29 Jul 2019 01:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D36688E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:42:52 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w5so37516489pgs.5
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:42:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=vgWidJp1DyKTPwyq6dR9hsFgPGq4asNb2UOZODn9yGQ=;
        b=qO36S+J51Kno3zhcIdxcSPxJOlvo17YvGJM87ZIbGSUKgIDMusTqpDa7YqdhxxgW51
         xRkpXoh/xCLB3u9/8zhbpRuQUS56mk43glJVQ9GHiGKloD04eCMk0LOR7L/swzIUL+6L
         2gfIC0wUjeMJwlvYYZC9Fsac4E6OQpslnZXFmwFNYHs3Uiah0LhWwietm9+hI3k2M3zw
         FFoq7aiwRZ8C3VfQdLk7efDNPMFRQm8oGPOPhLLb7lphw2l3VT0swEVnGpUwQEpeTchP
         h7kjHYhM6x3hj4kzFk0tNOH+JFuI+Qxf87zxphdK4tJPirtTptZcxcMjd5zrTcaSrat7
         svAQ==
X-Gm-Message-State: APjAAAXr8EHYRfzZcai9DoQoqQs6fzB1SBzCkve1fYOTVAxrDpR0Bm7P
	VOYgaP9hG75DwzTOHl/g1LRy1C2QNyRHOo0a3qRugwABGUlnU7Oe2g+aPL1ptOxa1HP6cUVqaKZ
	7tL+9VlynhC3HxKya/p86jbjbvyeK8VuEYJNNlFPSYjz9FQVqnvPxEc9hWRRNUThzPw==
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr111096153pjl.41.1564378972440;
        Sun, 28 Jul 2019 22:42:52 -0700 (PDT)
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr111096097pjl.41.1564378971319;
        Sun, 28 Jul 2019 22:42:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564378971; cv=none;
        d=google.com; s=arc-20160816;
        b=X6WQY5B/DAQLBj09lgA5yA5qJdgPhlmTYtl1S3U16qbMjspf0/2jlIjDeOmgY1m4lp
         nooapgLjuA2p7BQZ57jdNhU9OJtqnBySxB6z+NiydSDR1Gg1nWr270o1d+qF7eK0TTaR
         L8Tr82dS0q+Cs0czpdKsf1WX/a9nqhzOOZ043+Tf6DAFWN0mMPFT6KmRdqNnRz4aW0IE
         yaxQAl2w9XuwJoS42z3BUBrVWJLQpOz40xPVH0araJlpQJPOdFZRlcV1QtbAHuHXty6T
         Onz/k4fL2Nn2YUBGvP98PYbFIKo/jtjXlyvM+EPI2Y2CCMsuMv73zcThDWRg5g5wmNgq
         1inA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=vgWidJp1DyKTPwyq6dR9hsFgPGq4asNb2UOZODn9yGQ=;
        b=ldScKAZRBvWk/QgXBJ1ap8O8VBMYvHUvZqzjo2UvV3a84twvIhJfaAQKPTzMVne96y
         lDsWkmLBkFp6YKHYBmBORIPXLedu/WV45MkJcd+yIW8X8DGNKgig5OU1+UFDvXGTp3TX
         LUrZc66Q5eHFCHnnYv48stH/OgedGBmVTCZhdGZbGa22pWps9BSXWXbt1DqLefKd4mqn
         ETw5KZlqlOsv4/yb3xuSUBtNl1c483FzS45ZIGxQEgyiUteYjRj3euqC6jxCj6pVbzES
         VFcWbqFRRFLxoyq2IcHCvRAOL3pd54x/LM/I8u3ylsuLYs91EHmMACAtfwFsdVZY2t5e
         Futg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qxWwskZ3;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f32sor73804477pje.11.2019.07.28.22.42.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Jul 2019 22:42:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qxWwskZ3;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=vgWidJp1DyKTPwyq6dR9hsFgPGq4asNb2UOZODn9yGQ=;
        b=qxWwskZ3C+G1kw+A2FmYJoQv61D2xQZwsqpcFae5kfXhswGgnWidmxRQcnZrZ6yPZV
         mZwBU2UBbqOPpwc+oU3YfleOCfJYojBTTFZRCc15yxyWU7F3FaeZYSqy4NHGx3RNHUHN
         8cjLLQpsJxUiWXWELCqgOoKTzQqE+31m3ovrKt6oVQ153hZdbsiDWEHvIV5COLJfDPYU
         nwvbbod74iaAti79MsV8rp5T0RDGS+8mQ5YHzGKhKTt3OvZBrcLOkCozAjGPcjFc1LmH
         Qbjk8wF4T7aErnJLLioE6EGnjWdaOAUskIk3eL0Q09dvc5+R5kseZ0iBnu3FKC01l3t2
         lbxA==
X-Google-Smtp-Source: APXvYqwHkaLh7KKBYR49920g/O6KFmHx1WSzwkwKnft1/r1u1sWuU0ghjoM3tFGfASlWddJiinqypQ==
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr69619150pje.0.1564378970729;
        Sun, 28 Jul 2019 22:42:50 -0700 (PDT)
Received: from rashmica.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id n89sm77014876pjc.0.2019.07.28.22.42.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 28 Jul 2019 22:42:50 -0700 (PDT)
Message-ID: <b7de7d9d84e9dd47358a254d36f6a24dd48da963.camel@gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: Rashmica Gupta <rashmica.g@gmail.com>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, 
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com, 
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Mon, 29 Jul 2019 15:42:43 +1000
In-Reply-To: <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
References: <20190625075227.15193-1-osalvador@suse.de>
	 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
	 <20190626080249.GA30863@linux>
	 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
	 <20190626081516.GC30863@linux>
	 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
	 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
	 <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-07-16 at 14:28 +0200, David Hildenbrand wrote:
> On 02.07.19 08:42, Rashmica Gupta wrote:
> > Hi David,
> > 
> > Sorry for the late reply.
> 
> Hi,
> 
> sorry I was on PTO :)
> 
> > On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
> > > On 26.06.19 10:15, Oscar Salvador wrote:
> > > > On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand
> > > > wrote:
> > > > > Back then, I already mentioned that we might have some users
> > > > > that
> > > > > remove_memory() they never added in a granularity it wasn't
> > > > > added. My
> > > > > concerns back then were never fully sorted out.
> > > > > 
> > > > > arch/powerpc/platforms/powernv/memtrace.c
> > > > > 
> > > > > - Will remove memory in memory block size chunks it never
> > > > > added
> > > > > - What if that memory resides on a DIMM added via
> > > > > MHP_MEMMAP_DEVICE?
> > > > > 
> > > > > Will it at least bail out? Or simply break?
> > > > > 
> > > > > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is
> > > > > save
> > > > > to be
> > > > > introduced.
> > > > 
> > > > Uhm, I will take a closer look and see if I can clear your
> > > > concerns.
> > > > TBH, I did not try to use
> > > > arch/powerpc/platforms/powernv/memtrace.c
> > > > yet.
> > > > 
> > > > I will get back to you once I tried it out.
> > > > 
> > > 
> > > BTW, I consider the code in
> > > arch/powerpc/platforms/powernv/memtrace.c
> > > very ugly and dangerous.
> > 
> > Yes it would be nice to clean this up.
> > 
> > > We should never allow to manually
> > > offline/online pages / hack into memory block states.
> > > 
> > > What I would want to see here is rather:
> > > 
> > > 1. User space offlines the blocks to be used
> > > 2. memtrace installs a hotplug notifier and hinders the blocks it
> > > wants
> > > to use from getting onlined.
> > > 3. memory is not added/removed/onlined/offlined in memtrace code.
> > > 
> > 
> > I remember looking into doing it a similar way. I can't recall the
> > details but my issue was probably 'how does userspace indicate to
> > the kernel that this memory being offlined should be removed'?
> 
> Instead of indicating a "size", indicate the offline memory blocks
> that
> the driver should use. E.g. by memory block id for each node
> 
> 0:20-24,1:30-32
> 
> Of course, other interfaces might make sense.
> 
> You can then start using these memory blocks and hinder them from
> getting onlined (as a safety net) via memory notifiers.
> 
> That would at least avoid you having to call
> add_memory/remove_memory/offline_pages/device_online/modifying
> memblock
> states manually.

I see what you're saying and that definitely sounds safer.

We would still need to call remove_memory and add_memory from memtrace
as
just offlining memory doesn't remove it from the linear page tables
(if 
it's still in the page tables then hardware can prefetch it and if
hardware tracing is using it then the box checkstops).

> 
> (binding the memory block devices to a driver would be nicer, but the
> infrastructure is not really there yet - we have no such drivers in
> place yet)
> 
> > I don't know the mm code nor how the notifiers work very well so I
> > can't quite see how the above would work. I'm assuming memtrace
> > would
> > register a hotplug notifier and when memory is offlined from
> > userspace,
> > the callback func in memtrace would be called if the priority was
> > high
> > enough? But how do we know that the memory being offlined is
> > intended
> > for usto touch? Is there a way to offline memory from userspace not
> > using sysfs or have I missed something in the sysfs interface?
> 
> The notifier would really only be used to hinder onlining as a safety
> net. User space prepares (offlines) the memory blocks and then tells
> the
> drivers which memory blocks to use.
> 
> > On a second read, perhaps you are assuming that memtrace is used
> > after
> > adding new memory at runtime? If so, that is not the case. If not,
> > then
> > would you be able to clarify what I'm not seeing?
> 
> The main problem I see is that you are calling
> add_memory/remove_memory() on memory your device driver doesn't own.
> It
> could reside on a DIMM if I am not mistaking (or later on
> paravirtualized memory devices like virtio-mem if I ever get to
> implement them ;) ).

This is just for baremetal/powernv so shouldn't affect virtual memory
devices.

> 
> How is it guaranteed that the memory you are allocating does not
> reside
> on a DIMM for example added via add_memory() by the ACPI driver?

Good point. We don't have ACPI on powernv but currently this would try
to remove memory from any online memory node, not just the ones that
are backed by RAM. oops.


