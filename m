Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F14C5C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A590720674
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:51:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A590720674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 412C26B0005; Wed, 24 Apr 2019 15:51:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C21F6B0006; Wed, 24 Apr 2019 15:51:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B3A56B0007; Wed, 24 Apr 2019 15:51:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEE026B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:51:19 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j22so2099447wre.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:51:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=WcwpYdXiXw/CQPBbfKfYuXWd8xPWqgN2d4maqJEk8aY=;
        b=TQuzU855VCHseUn2Bqgk+xNcy76FexF9oSI01EPpUqIDjE2uNJgdCgGUZF4kmhPgtP
         AlrVW9lkSQv8K5B8QqhDY4f3kQuVAY2EIOpXFAqFn0S316GN1hQwlXPuyJ+R6K2x0P9D
         5LmkA4O2xSsvJIIF6aZZle7qbYz+aMoczwFLYhugfzOvtkakGeXT0957NzVlFctEYsFY
         v6kmwYbieSjFx8zIpRCciBI0cAR39Yzg5o5SYpwf/5V+VJ3uyw6ucbNm1/pLy6VzztjS
         G4ygB5weHOWVBq1MuovnQvJys4sdiSMywyn5Hu8kEjwd3D127ax9DZrJcgbu/o8QBnoX
         AMUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVOUObHMR9PTpprulZvBBgro/iI2Fg/vMDk4wong0fDQnHzB5/j
	UqLJDnipsgdk8d7vFYNuCR0v+zuBGZo1mLTPbc9wnIlt51Hpwd7YAT1OP1D9mXOyQNIMH+aOUJP
	eBt1sGGmStanGQ1F956WqJUdp1hCDlrRiRvInddn+sevq4n0AK6Jocnzbo2D4MrNf/Q==
X-Received: by 2002:a7b:cb58:: with SMTP id v24mr516467wmj.121.1556135479421;
        Wed, 24 Apr 2019 12:51:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwu6yKK9G6xvv9lL6NIPCzYUjWIm8/d18mba8dM5rijSeMSQVSAcvC4DpX3+RVvxR0Whccz
X-Received: by 2002:a7b:cb58:: with SMTP id v24mr516435wmj.121.1556135478666;
        Wed, 24 Apr 2019 12:51:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135478; cv=none;
        d=google.com; s=arc-20160816;
        b=nU1Hbl35IT2xxUMUXjYlxMbz/7lIPox5BrtRoykNSSf0WILl5dA596yBL076KrYBj+
         Hsh3e86902rXIU52mZNE8AyXq1HMlqks4YAg+tv1eiJ8tnO1tQ3y+rZL4X+lPW3k4jq7
         NJcdcom7+i7piBI134L/yB11bzq1f2Tur/ZrY5OzV7fsv+zFZT7A9KGsHKMVhS6NwX3p
         XTJKDPcAZnUP9HRSnazFvPJm8aEfcS6cwTaJJtKvIhiWvmbeLO+KzvKVBbx1jgKwEXtM
         4oHB+0XYJt5lzpChT9wDWKJ8oHV95UgB0Vk5HMtfrcjHCbkiTvsya4fYCpRB1I6R1k4T
         1ISA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=WcwpYdXiXw/CQPBbfKfYuXWd8xPWqgN2d4maqJEk8aY=;
        b=FCZWL677REU/s7F3AovVQ1Wr2e83Nt+GcQmYVwOlN2OqC46J4Jarm1sJm1v5CxzPS2
         wli+ZEciHGPc8VgZyd3R1ndJ4DwffX7UVeQhtbNvSTSs6z2JZ5pUUyiVrspXsHpfNmi2
         A2z2oLrwNGaE2x82cDvjrmnAjJbM+SNUNdHKyaXkRGR/0x0gt8DI2diQnEQImcLvPFoh
         tS/cCoJK/4DlXJ7uZ2S3y+J+Y2tB5xVl2Y729X1iv9Fv+FR3HtWxzY+0Y2Ip0/xSxsMV
         v6YslIIq4vGaQpnxBrnlzJvdKKCYk7pWIxnVr56Qqnk1SM50QN2n9XDxbaHWXcoQPq/c
         1Wqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l14si13774869wmc.80.2019.04.24.12.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 12:51:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5de0b374.dip0.t-ipconnect.de ([93.224.179.116] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hJNv9-0005Zr-Gt; Wed, 24 Apr 2019 21:51:07 +0200
Date: Wed, 24 Apr 2019 21:51:05 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 18/29] lockdep: Move stack trace logic into
 check_prev_add()
In-Reply-To: <20190424194505.GR11158@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.21.1904242148480.1762@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084254.729689921@linutronix.de> <20190424194505.GR11158@hirez.programming.kicks-ass.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2019, Peter Zijlstra wrote:
> On Thu, Apr 18, 2019 at 10:41:37AM +0200, Thomas Gleixner wrote:
> > There is only one caller of check_prev_add() which hands in a zeroed struct
> > stack trace and a function pointer to save_stack(). Inside check_prev_add()
> > the stack_trace struct is checked for being empty, which is always
> > true. Based on that one code path stores a stack trace which is unused. The
> > comment there does not make sense either. It's all leftovers from
> > historical lockdep code (cross release).
> 
> I was more or less expecting a revert of:
> 
> ce07a9415f26 ("locking/lockdep: Make check_prev_add() able to handle external stack_trace")
> 
> And then I read the comment that went with the "static struct
> stack_trace trace" that got removed (in the above commit) and realized
> that your patch will consume more stack entries.
> 
> The problem is when the held lock stack in check_prevs_add() has multple
> trylock entries on top, in that case we call check_prev_add() multiple
> times, and this patch will then save the exact same stack-trace multiple
> times, consuming static resources.
> 
> Possibly we should copy what stackdepot does (but we cannot use it
> directly because stackdepot uses locks; but possible we can share bits),
> but that is a patch for another day I think.
> 
> So while convoluted, perhaps we should retain this code for now.

Uurg, what a mess.

