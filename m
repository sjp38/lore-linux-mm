Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96AA76B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:40:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c139-v6so17536470qkg.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:40:41 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id k73-v6si1754801qke.106.2018.06.19.06.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 06:40:40 -0700 (PDT)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 6d9c0d29
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 13:34:47 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id c67a7c95 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 19 Jun 2018 13:34:46 +0000 (UTC)
Received: by mail-ot0-f180.google.com with SMTP id q17-v6so22590126otg.2
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 06:40:38 -0700 (PDT)
MIME-Version: 1.0
References: <CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com>
 <CALvZod6Dxx79ztxzHsDVe6pj7Fa7ydJAjMf_EHV9H15+AsVwdA@mail.gmail.com>
 <CAHmME9qvRDQOJYdSPaAf-hg5raacu4TBgStLy7NzFL+j+dXheQ@mail.gmail.com>
 <CALvZod5ZrxjZjJjAV_iH6hgq9pY2QEuFjNi+qvPSzob5Vighjg@mail.gmail.com>
 <CAHmME9r=+91YtujYqsBwf52VkCdPMD8VXJED_AsR42H5h9--mA@mail.gmail.com> <CACT4Y+b+9HK8Ti_iXA1DcHDeTR+Cj-xaQ+kQpvc7xPNafk5tkw@mail.gmail.com>
In-Reply-To: <CACT4Y+b+9HK8Ti_iXA1DcHDeTR+Cj-xaQ+kQpvc7xPNafk5tkw@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 19 Jun 2018 15:40:26 +0200
Message-ID: <CAHmME9q3Cwba4Z=cnosOrDUAWEHtYQ9FZ6hsDpOS4czvc6DJJg@mail.gmail.com>
Subject: Re: Possible regression in "slab, slub: skip unnecessary kasan_cache_shutdown()"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2018 at 3:31 PM Dmitry Vyukov <dvyukov@google.com> wrote:
> Since I already looked at the code, if init and uninit can be called
> concurrently, I think there is a prominent race condition between init
> and uninit: a concurrent uninit can run concurrnetly with the next
> init and this will totally mess things up.

Good point; fixed. Though this doesn't have any effect on the issue here. :)
