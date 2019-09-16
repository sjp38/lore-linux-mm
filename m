Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B16C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 21:31:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0222020644
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 21:31:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gLPaySJP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0222020644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721556B0003; Mon, 16 Sep 2019 17:31:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D2C46B0006; Mon, 16 Sep 2019 17:31:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C0836B0007; Mon, 16 Sep 2019 17:31:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9176B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 17:31:40 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CFC48812C
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:31:39 +0000 (UTC)
X-FDA: 75942080718.23.scale70_48a39bdfcfb28
X-HE-Tag: scale70_48a39bdfcfb28
X-Filterd-Recvd-Size: 13726
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:31:38 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id d2so1747428qtr.4
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:31:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=OtI/pUMWSUWHSxCto+5Y9kOxVYNA3dv2B6oM7vamPh0=;
        b=gLPaySJPgGayIegWWI0zvrhMtv1ZMT+Fqgi/18YKjQ0dcFvSkf9vl6hki/2iMchqhz
         HmKzECaovdJ/2WbTha4LaX6re99tRsczM4VCE6/77v33tQmzh5ofT4SrD6JcB0CUT5Y1
         2o5WFiRPlUDIDhV5CWCalFyL9Onc8ZMcDK8hF0A039ePT6gR0AdKK9E3chrujS9HJdVd
         C9dLMFQH6KJYNRwtjoJXq06vDcGMq/iIMMouSxFaoX+KuktKIVTmLsBZT/bkx9j+LP2D
         tZKLUfG9fqYZAfEPamwucQhjzPiKhMm0mdUnXHu+7HL6UJGwOvA5WJ+jKqOUCMKDiAWN
         gV9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=OtI/pUMWSUWHSxCto+5Y9kOxVYNA3dv2B6oM7vamPh0=;
        b=FiLCvZdAd27zgvfhjOkLfCkbbqVeWoQW7EG68f5M3t3tHAUvkzQLI7C9rWco2EPs7k
         HZECq1tXkNAC10xlgH6nXlWLUiIuqd2jBLknatOeB5SEtE1XKNt1g9l4xTRFbwdCMSbK
         Y80rmVIVMbC8OI9vWeDlsDhD/TasTa29glJd7X/RR0yf8TimVx+zQnih8un6lqqrZikG
         fJE3wDMKI4x92tAOwI8aVon0X8wh1zRy3aZHyEvQdLlTxMpSHKBFD4tCCaTluTQ38ZJW
         S+Dr04PTlA8Ksh4fHteUOxrKUV+z8OP/e0gMVzrIzms02c3cOevEjJ2DZgRuLxZeP56H
         nxyQ==
X-Gm-Message-State: APjAAAVIGrN12niYWa7P8Za46H9gmzXefsvv0GPM102AkaKiN0KOHVOE
	QJmK7NeZrlR5h7s00rfNgh45ng==
X-Google-Smtp-Source: APXvYqzNb9g9p/4qXQKa/UG9J98LCdjGB5VAXKUg4IHbiS+k0l5/307LRG6Wvg6h7NxSYsm0DSUYvA==
X-Received: by 2002:a0c:c251:: with SMTP id w17mr369272qvh.226.1568669497775;
        Mon, 16 Sep 2019 14:31:37 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id a4sm115016qkf.91.2019.09.16.14.31.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 14:31:37 -0700 (PDT)
Message-ID: <1568669494.5576.157.camel@lca.pw>
Subject: Re: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
From: Qian Cai <cai@lca.pw>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, 
 tglx@linutronix.de, thgarnie@google.com, tytso@mit.edu, cl@linux.com, 
 penberg@kernel.org, rientjes@google.com, will@kernel.org,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org, keescook@chromium.org
Date: Mon, 16 Sep 2019 17:31:34 -0400
In-Reply-To: <20190916195115.g4hj3j3wstofpsdr@linutronix.de>
References: <1568392064-3052-1-git-send-email-cai@lca.pw>
	 <20190916090336.2mugbds4rrwxh6uz@linutronix.de>
	 <1568642487.5576.152.camel@lca.pw>
	 <20190916195115.g4hj3j3wstofpsdr@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000107, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-16 at 21:51 +0200, Sebastian Andrzej Siewior wrote:
> On 2019-09-16 10:01:27 [-0400], Qian Cai wrote:
> > On Mon, 2019-09-16 at 11:03 +0200, Sebastian Andrzej Siewior wrote:
> > > On 2019-09-13 12:27:44 [-0400], Qian Cai wrote:
> > > =E2=80=A6
> > > > Chain exists of:
> > > >   random_write_wait.lock --> &rq->lock --> batched_entropy_u32.lo=
ck
> > > >=20
> > > >  Possible unsafe locking scenario:
> > > >=20
> > > >        CPU0                    CPU1
> > > >        ----                    ----
> > > >   lock(batched_entropy_u32.lock);
> > > >                                lock(&rq->lock);
> > > >                                lock(batched_entropy_u32.lock);
> > > >   lock(random_write_wait.lock);
> > >=20
> > > would this deadlock still occur if lockdep knew that
> > > batched_entropy_u32.lock on CPU0 could be acquired at the same time
> > > as CPU1 acquired its batched_entropy_u32.lock?
> >=20
> > I suppose that might fix it too if it can teach the lockdep the trick=
, but it
> > would be better if there is a patch if you have something in mind tha=
t could be
> > tested to make sure.
>=20
> get_random_bytes() is heavier than get_random_int() so I would prefer t=
o
> avoid its usage to fix what looks like a false positive report from
> lockdep.
> But no, I don't have a patch sitting around. A lock in per-CPU memory
> could lead to the scenario mentioned above if the lock could be obtaine=
d
> cross-CPU it just isn't so in that case. So I don't think it is that
> simple.

get_random_u64() is also busted.

[=C2=A0=C2=A0752.925079] WARNING: possible circular locking dependency de=
tected
[=C2=A0=C2=A0752.931951] 5.3.0-rc8-next-20190915+ #2 Tainted: G=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0L=C2=A0=
=C2=A0=C2=A0
[=C2=A0=C2=A0752.938906] ------------------------------------------------=
------
[=C2=A0=C2=A0752.945774] ls/9665 is trying to acquire lock:
[=C2=A0=C2=A0752.950905] ffff90001311fef8 (random_write_wait.lock){..-.},=
 at:
__wake_up_common_lock+0xa8/0x11c
[=C2=A0=C2=A0752.960481]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0but task is already holding lock:
[=C2=A0=C2=A0752.967698] ffff008abc7b9c00 (batched_entropy_u64.lock){....=
}, at:
get_random_u64+0x6c/0x1dc
[=C2=A0=C2=A0752.976835]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0which lock already depends on the new lock.

[=C2=A0=C2=A0752.987089]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0the existing dependency chain (in reverse order) is:
[=C2=A0=C2=A0752.995953]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0-> #4 (batched_entropy_u64.lock){....}:
[=C2=A0=C2=A0753.003702]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x320/0x364
[=C2=A0=C2=A0753.008577]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x7c/0x9c
[=C2=A0=C2=A0753.014145]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_random_u64+0x6c/0x1dc
[=C2=A0=C2=A0753.019109]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
dd_to_free_area_random+0x54/0x1c8
[=C2=A0=C2=A0753.024851]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0f=
ree_one_page+0x86c/0xc28
[=C2=A0=C2=A0753.029818]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages_ok+0x69c/0xdac
[=C2=A0=C2=A0753.034960]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages+0xbc/0xf8
[=C2=A0=C2=A0753.039663]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages_core+0x2ac/0x3c0
[=C2=A0=C2=A0753.044973]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emblock_free_pages+0xe0/0xf8
[=C2=A0=C2=A0753.050281]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages_memory+0xcc/0xfc
[=C2=A0=C2=A0753.055588]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_memory_core+0x70/0x78
[=C2=A0=C2=A0753.060809]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0f=
ree_low_memory_core_early+0x148/0x18c
[=C2=A0=C2=A0753.066897]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emblock_free_all+0x18/0x54
[=C2=A0=C2=A0753.072033]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
em_init+0x9c/0x160
[=C2=A0=C2=A0753.076472]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
m_init+0x14/0x38
[=C2=A0=C2=A0753.080737]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_kernel+0x19c/0x52c
[=C2=A0=C2=A0753.085607]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0-> #3 (&(&zone->lock)->rlock){..-.}:
[=C2=A0=C2=A0753.093092]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x320/0x364
[=C2=A0=C2=A0753.097964]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x64/0x80
[=C2=A0=C2=A0753.102839]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
mqueue_bulk+0x50/0x15a0
[=C2=A0=C2=A0753.107712]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_page_from_freelist+0x2260/0x29dc
[=C2=A0=C2=A0753.113627]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_alloc_pages_nodemask+0x36c/0x1ce0
[=C2=A0=C2=A0753.119457]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_page_interleave+0x34/0x17c
[=C2=A0=C2=A0753.125023]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_pages_current+0x80/0xe0
[=C2=A0=C2=A0753.130334]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
llocate_slab+0xfc/0x1d80
[=C2=A0=C2=A0753.135296]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
__slab_alloc+0x5d4/0xa70
[=C2=A0=C2=A0753.140257]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
mem_cache_alloc+0x588/0x66c
[=C2=A0=C2=A0753.145480]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_debug_object_init+0x9d8/0xbac
[=C2=A0=C2=A0753.150962]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
ebug_object_init+0x40/0x50
[=C2=A0=C2=A0753.156098]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
rtimer_init+0x38/0x2b4
[=C2=A0=C2=A0753.160885]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
nit_dl_task_timer+0x24/0x44
[=C2=A0=C2=A0753.166108]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_sched_fork+0xc0/0x168
[=C2=A0=C2=A0753.170894]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
nit_idle+0x80/0x3d8
[=C2=A0=C2=A0753.175420]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0i=
dle_thread_get+0x60/0x8c
[=C2=A0=C2=A0753.180385]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
cpu_up+0x10c/0x348
[=C2=A0=C2=A0753.184824]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_cpu_up+0x114/0x170
[=C2=A0=C2=A0753.189437]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
pu_up+0x20/0x2c
[=C2=A0=C2=A0753.193615]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
mp_init+0xf8/0x1bc
[=C2=A0=C2=A0753.198054]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init_freeable+0x198/0x26c
[=C2=A0=C2=A0753.203622]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init+0x18/0x334
[=C2=A0=C2=A0753.208323]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
et_from_fork+0x10/0x18
[=C2=A0=C2=A0753.213107]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0-> #2 (&rq->lock){-.-.}:
[=C2=A0=C2=A0753.219550]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x320/0x364
[=C2=A0=C2=A0753.224423]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x64/0x80
[=C2=A0=C2=A0753.229299]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ask_fork_fair+0x64/0x22c
[=C2=A0=C2=A0753.234261]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
ched_fork+0x24c/0x3d8
[=C2=A0=C2=A0753.238962]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
opy_process+0xa60/0x29b0
[=C2=A0=C2=A0753.243921]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
do_fork+0xb8/0xa64
[=C2=A0=C2=A0753.248360]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_thread+0xc4/0xf4
[=C2=A0=C2=A0753.253147]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
est_init+0x30/0x320
[=C2=A0=C2=A0753.257673]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
rch_call_rest_init+0x10/0x18
[=C2=A0=C2=A0753.262980]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_kernel+0x424/0x52c
[=C2=A0=C2=A0753.267849]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0-> #1 (&p->pi_lock){-.-.}:
[=C2=A0=C2=A0753.274467]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x320/0x364
[=C2=A0=C2=A0753.279342]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x7c/0x9c
[=C2=A0=C2=A0753.284910]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ry_to_wake_up+0x74/0x128c
[=C2=A0=C2=A0753.289959]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
efault_wake_function+0x38/0x48
[=C2=A0=C2=A0753.295440]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
ollwake+0x118/0x158
[=C2=A0=C2=A0753.299967]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_wake_up_common+0x16c/0x240
[=C2=A0=C2=A0753.305187]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_wake_up_common_lock+0xc8/0x11c
[=C2=A0=C2=A0753.310754]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_wake_up+0x3c/0x4c
[=C2=A0=C2=A0753.315193]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
ccount+0x390/0x3e0
[=C2=A0=C2=A0753.319632]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
xtract_entropy+0x2cc/0x37c
[=C2=A0=C2=A0753.324766]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
xfer_secondary_pool+0x35c/0x3c4
[=C2=A0=C2=A0753.330333]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
ush_to_pool+0x54/0x308
[=C2=A0=C2=A0753.335119]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rocess_one_work+0x558/0xb1c
[=C2=A0=C2=A0753.340339]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0w=
orker_thread+0x494/0x650
[=C2=A0=C2=A0753.345300]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
thread+0x1cc/0x1e8
[=C2=A0=C2=A0753.349739]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
et_from_fork+0x10/0x18
[=C2=A0=C2=A0753.354522]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0-> #0 (random_write_wait.lock){..-.}:
[=C2=A0=C2=A0753.362093]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
alidate_chain+0xfcc/0x2fd4
[=C2=A0=C2=A0753.367227]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x868/0xc2c
[=C2=A0=C2=A0753.372274]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x320/0x364
[=C2=A0=C2=A0753.377147]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x7c/0x9c
[=C2=A0=C2=A0753.382715]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_wake_up_common_lock+0xa8/0x11c
[=C2=A0=C2=A0753.388282]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_wake_up+0x3c/0x4c
[=C2=A0=C2=A0753.392720]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
ccount+0x390/0x3e0
[=C2=A0=C2=A0753.397159]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
xtract_entropy+0x2cc/0x37c
[=C2=A0=C2=A0753.402292]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
rng_reseed+0x60/0x350
[=C2=A0=C2=A0753.406991]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
extract_crng+0xd8/0x164
[=C2=A0=C2=A0753.411864]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
rng_reseed+0x7c/0x350
[=C2=A0=C2=A0753.416563]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
extract_crng+0xd8/0x164
[=C2=A0=C2=A0753.421436]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_random_u64+0xec/0x1dc
[=C2=A0=C2=A0753.426396]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
rch_mmap_rnd+0x18/0x78
[=C2=A0=C2=A0753.431187]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
oad_elf_binary+0x6d0/0x1730
[=C2=A0=C2=A0753.436411]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
earch_binary_handler+0x10c/0x35c
[=C2=A0=C2=A0753.442067]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_do_execve_file+0xb58/0xf7c
[=C2=A0=C2=A0753.447287]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_arm64_sys_execve+0x6c/0xa4
[=C2=A0=C2=A0753.452509]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc_handler+0x170/0x240
[=C2=A0=C2=A0753.457643]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc+0x8/0xc
[=C2=A0=C2=A0753.461732]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0other info that might help us debug this:

[=C2=A0=C2=A0753.471812] Chain exists of:
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0random_write_wait.lock --> &(&zone->lock)->rlo=
ck -->
batched_entropy_u64.lock

[=C2=A0=C2=A0753.486588]=C2=A0=C2=A0Possible unsafe locking scenario:

[=C2=A0=C2=A0753.493890]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0C=
PU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
[=C2=A0=C2=A0753.499108]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-=
---=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
[=C2=A0=C2=A0753.504324]=C2=A0=C2=A0=C2=A0lock(batched_entropy_u64.lock);
[=C2=A0=C2=A0753.509372]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&zone->lock)->rlock);
[=C2=A0=C2=A0753.516675]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(ba=
tched_entropy_u64.lock);
[=C2=A0=C2=A0753.524238]=C2=A0=C2=A0=C2=A0lock(random_write_wait.lock);
[=C2=A0=C2=A0753.529113]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0*** DEADLOCK ***

[=C2=A0=C2=A0753.537111] 1 lock held by ls/9665:
[=C2=A0=C2=A0753.541287]=C2=A0=C2=A0#0: ffff008abc7b9c00 (batched_entropy=
_u64.lock){....}, at:
get_random_u64+0x6c/0x1dc
[=C2=A0=C2=A0753.550858]=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0stack backtrace:
[=C2=A0=C2=A0753.556602] CPU: 121 PID: 9665 Comm: ls Tainted: G=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0L=C2=A0=
=C2=A0=C2=A0=C2=A05.3.0-
rc8-next-20190915+ #2
[=C2=A0=C2=A0753.565987] Hardware name: HPE Apollo 70=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/C01_APACHE_MB=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0,
BIOS L50_5.13_1.11 06/18/2019
[=C2=A0=C2=A0753.576414] Call trace:
[=C2=A0=C2=A0753.579553]=C2=A0=C2=A0dump_backtrace+0x0/0x264
[=C2=A0=C2=A0753.583905]=C2=A0=C2=A0show_stack+0x20/0x2c
[=C2=A0=C2=A0753.587911]=C2=A0=C2=A0dump_stack+0xd0/0x140
[=C2=A0=C2=A0753.592003]=C2=A0=C2=A0print_circular_bug+0x368/0x380
[=C2=A0=C2=A0753.596876]=C2=A0=C2=A0check_noncircular+0x28c/0x294
[=C2=A0=C2=A0753.601664]=C2=A0=C2=A0validate_chain+0xfcc/0x2fd4
[=C2=A0=C2=A0753.606276]=C2=A0=C2=A0__lock_acquire+0x868/0xc2c
[=C2=A0=C2=A0753.610802]=C2=A0=C2=A0lock_acquire+0x320/0x364
[=C2=A0=C2=A0753.615154]=C2=A0=C2=A0_raw_spin_lock_irqsave+0x7c/0x9c
[=C2=A0=C2=A0753.620202]=C2=A0=C2=A0__wake_up_common_lock+0xa8/0x11c
[=C2=A0=C2=A0753.625248]=C2=A0=C2=A0__wake_up+0x3c/0x4c
[=C2=A0=C2=A0753.629171]=C2=A0=C2=A0account+0x390/0x3e0
[=C2=A0=C2=A0753.633095]=C2=A0=C2=A0extract_entropy+0x2cc/0x37c
[=C2=A0=C2=A0753.637708]=C2=A0=C2=A0crng_reseed+0x60/0x350
[=C2=A0=C2=A0753.641887]=C2=A0=C2=A0_extract_crng+0xd8/0x164
[=C2=A0=C2=A0753.646238]=C2=A0=C2=A0crng_reseed+0x7c/0x350
[=C2=A0=C2=A0753.650417]=C2=A0=C2=A0_extract_crng+0xd8/0x164
[=C2=A0=C2=A0753.654768]=C2=A0=C2=A0get_random_u64+0xec/0x1dc
[=C2=A0=C2=A0753.659208]=C2=A0=C2=A0arch_mmap_rnd+0x18/0x78
[=C2=A0=C2=A0753.663474]=C2=A0=C2=A0load_elf_binary+0x6d0/0x1730
[=C2=A0=C2=A0753.668173]=C2=A0=C2=A0search_binary_handler+0x10c/0x35c
[=C2=A0=C2=A0753.673308]=C2=A0=C2=A0__do_execve_file+0xb58/0xf7c
[=C2=A0=C2=A0753.678007]=C2=A0=C2=A0__arm64_sys_execve+0x6c/0xa4
[=C2=A0=C2=A0753.682707]=C2=A0=C2=A0el0_svc_handler+0x170/0x240
[=C2=A0=C2=A0753.687319]=C2=A0=C2=A0el0_svc+0x8/0xc

