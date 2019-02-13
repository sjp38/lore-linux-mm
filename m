Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 254E5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D659E222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D659E222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AEEE8E0002; Wed, 13 Feb 2019 04:27:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55DE88E0001; Wed, 13 Feb 2019 04:27:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44E7F8E0002; Wed, 13 Feb 2019 04:27:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB9C38E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:27:57 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t21so337312wmt.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:27:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GKjV3LCbmcnlhk4L7+Wz5JQXz00WoPv7LODUBCCVFg8=;
        b=Z60/AtV3Vvcd5cyKLqyB1jRyrO9Nl5dQtFwts++hj24tjwL+Ka8ebu7IFd2jG2f6yJ
         ajK8h5JUC+Oelt+xNLR5zDR0BNu1em8mgpWrHWVAx7FNx40Zp3HvPH1B/IPUvxsrWvQP
         EcqIj/c7BP8nIaKqTfQjxLgp7o/KFMOR4Uipm44tVmWi/27kf+/nHeHDrXFZR2LWVW/t
         KEnIyiybwTjSyLAfCrAoc+hdDEfVmP0Mz7s5HMOQe8+C7OryYYFtSkagO1Wv9XPQJiNw
         fd3QE9V/HQN6Oun301rfusK89JuSUNzyyUpmEc/MsYbGrmuMH0+TgmBvTsGufjGhV9mT
         nzJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: AHQUAuZKt7UUxdqGzEH8lgGJqD7lqbrDOxKePaOwmHWid+YJIWbeA3Ys
	0Oe+DxuA3THJI45zQh2Up/+glw5kIeYkmFtRRRrF/lpqwfkAf/qV0pgUolxYq0M6eAQdDrmQAgn
	BJD1uRG3nt4Kl8toi0Ggm9+NFVt9MUQfgGRhnXbo4poNSy8d+1yw6MIrqh+BCCKYvuw==
X-Received: by 2002:adf:ce91:: with SMTP id r17mr5940619wrn.80.1550050077433;
        Wed, 13 Feb 2019 01:27:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMjk52uyHDhVmmdFKQlpal99zHY3cNEDx44IpDDD/BmY7zXVDgvY3KBYR4B8rb35ZdmqFj
X-Received: by 2002:adf:ce91:: with SMTP id r17mr5940584wrn.80.1550050076561;
        Wed, 13 Feb 2019 01:27:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550050076; cv=none;
        d=google.com; s=arc-20160816;
        b=u6SdEldobJyyikK/qgnWznSHFCsrcnqDe/J/uP48Kufd/Xv3eQBqvez2vPneUTPpLw
         p6fE1hLKeGgdHCiYlib/ODfEOR5JkoS5x7BbEdQ484U/mtFLpVLUZqpBVTgBaAhJS85l
         iLGgEOWEajxldXMZWbsdnQ6z2l/c4YAX5lLr8wvGLtHGUSrb08kniFW44W0rbWYSue0t
         l68ZRPhPlEaM8ZVQhU6qOxCkR/yp/dHalJI/uuNxgN5MHHUILiXmV/+KN5WXyffW3TnY
         +sqzsnQ5qxBAwIpy9Ods8FdFCUge8nWDipqoWb+3+jpcM7F0+cAMkLwVWHdrANSXs+RT
         F+Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=GKjV3LCbmcnlhk4L7+Wz5JQXz00WoPv7LODUBCCVFg8=;
        b=fii+ElWLoQQJ42+NjGoC2S6sj09NYotHXOrcYI8yF20SaOr3QifFmbIG0g1bB2zjZw
         6cwox8uBnKJHB38NbztyRZ3Q36WPiMh7OkiU7Yn7fzbJyxtIRSAdC0Yx5oMzYx2tHNwO
         BYzkX2ZaF7jewJT3hV9b7M2VhP6LLB3DF1mKJhIWOZDhLhK7qywYKfk8lIkfeYkvwcEe
         kbz0UHDkLPq88dCNJm6Aqs+tgvmNpJVEPr08f0RHGgYnLnNm1kcso1I2qdwKf8tDX6WU
         b4b1/Fm6PKr/SgWYizx0v49rm7sCRn5YJ7SPKso/mCZvdi+dySYyvzi3pkuXhIeWm6PQ
         fw1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u10si11829155wri.123.2019.02.13.01.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 01:27:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1gtqpe-0004XT-Mt; Wed, 13 Feb 2019 10:27:54 +0100
Date: Wed, 13 Feb 2019 10:27:54 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190213092754.baxi5zpe7kdpf3bj@linutronix.de>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
 <20190211210208.GA9580@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190211210208.GA9580@cmpxchg.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-02-11 16:02:08 [-0500], Johannes Weiner wrote:
> > how do you define safe? I've been looking for dependencies of
> > __mod_lruvec_state() but found only that the lock is held during the RMW
> > operation with WORKINGSET_NODES idx.
>=20
> These stat functions are not allowed to nest, and the executing thread
> cannot migrate to another CPU during the operation, otherwise they
> corrupt the state they're modifying.

If everyone is taking the same lock (like i_pages.xa_lock) then there
will not be two instances updating the same stat. The owner of the
(sleeping)-spinlock will not be migrated to another CPU.

> They are called from interrupt handlers, such as when NR_WRITEBACK is
> decreased. Thus workingset_node_update() must exclude preemption from
> irq handlers on the local CPU.

Do you have an example for a code path to check NR_WRITEBACK?
=20
> They rely on IRQ-disabling to also disable CPU migration.
The spinlock disables CPU migration.=20

> > >                                            I'm guessing it's because
> > > preemption is disabled and irq handlers are punted to process context.
> > preemption is enabled and IRQ are processed in forced-threaded mode.
>=20
> That doesn't sound safe.

Do you have test-case or something I could throw at it and verify that
this still works? So far nothing complains=E2=80=A6

Sebastian

