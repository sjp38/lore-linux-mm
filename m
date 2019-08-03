Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 895CBC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 09:20:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C2EF21783
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 09:20:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ptvr43dy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C2EF21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C55C6B0003; Sat,  3 Aug 2019 05:20:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677396B0005; Sat,  3 Aug 2019 05:20:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 516A96B0006; Sat,  3 Aug 2019 05:20:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC986B0003
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 05:20:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so49856131pfe.1
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 02:20:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=sTbQB+VsKCHhUtNcj2pWgbGTC92dmneZIV20ww0P/GA=;
        b=EbcQIfCkfvRlH/0GLT9U+OW3qQD921UHfsgOykutA/l0VDlfdopVykSYN7+eRBAZSL
         GW9LnMfIheFxKCMiXr4OShXg8VeKEIr7U+h8cFbqPxJz8ljCxvdpU/6FxlMf4Day44no
         6Yp/IC4BWBGiTK+QnXT2Wsr5o3Glz8VzDJMrIgabXQENCA4hJlM/LRGUTleYAav7mP2d
         iRvZL6E0gzECM0Wl94SINcLHptSCQB/egIF9GVG1FzIUEWHYzywzzuHakQqBYt6nmTwM
         ZtOYJbPtuHPoevjfZ40s99YREPgIGoshYtuyKxMyf7CT1XYRHaailBTRXm90BBXzTDIU
         E3FQ==
X-Gm-Message-State: APjAAAXch8WrCt+o1WJKKjvw6aQu8arFCjAybq9NwjMayGjBC4ZEfhms
	uknpPPeWYQ8xBg/rqoRmX49ekYqan8wBiOeowLLDlt5fqKJTyIl4Jlz3fFm8ZaOfVYUXV3Qfwtu
	N79VmEFzw7Uj+KMVo345LZoVRPk5lf5JbYFVvFYC8doPKD5uv1O9TffSY6AJ/eg76qw==
X-Received: by 2002:a17:90a:1ae2:: with SMTP id p89mr7971068pjp.26.1564824000670;
        Sat, 03 Aug 2019 02:20:00 -0700 (PDT)
X-Received: by 2002:a17:90a:1ae2:: with SMTP id p89mr7971034pjp.26.1564823999852;
        Sat, 03 Aug 2019 02:19:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564823999; cv=none;
        d=google.com; s=arc-20160816;
        b=ULHpnn7EvJiqE33QrDE++qZJtqO/3kZ57cHbQ+ru4F72ej/+KYfE/xChbj03+eEFM4
         0rWjdpOAjhwatd94AgPnBpDqK3fpjvrO8UcxO4IYZ+AshFa8e9+n0426qqhT0RW6eWy+
         lKl31K9RbN2tcbn59knb8qo5OEJecDRIgeS9Wv3lQaPUfh3pxijHulGJMRpgdgfJqwDK
         8XJ5pk2huvmOn7y8ne/ZHV9Xhamm3PaU/CiBCE3oOrrNiMB7K4HA++KWFhmPoUXVgU8b
         9MpGDNckK1gEwvCQRMAM6EDPuBIgz6ot17OH+og+7jFL+MvW8zJASCioSfYnBFGqxa32
         NLQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=sTbQB+VsKCHhUtNcj2pWgbGTC92dmneZIV20ww0P/GA=;
        b=K7GzIkiikc8O09gXJE+jLrjoX1GBkQuzoIVwJNMRh5dQRYGZOO3jclRnRTCQvryJWB
         SIkh4+JrAnQtyNuUoZartR1w+WzGQFJz8AcmJCZNBa/+KNoAXCqFkkjC3JQFzIXHWt9m
         d/vqfwDeyx1XFWS97M467iWKXye1LikrPGNiLkQencYug23+8d4ERCRTNpUS2pvtZh5L
         HgrvcP3ojasT18DGbHWr/AqmnH29yEnf1l9EyX5nqd46bHK+MYx2VQmLqH/MysHyICm0
         LA+q0rl67jpjGcjzenzo76+DQgzvCWn7tHOeVp0bMYYFCwpFZvBWy5vY3/tpnrANMNn0
         YlUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ptvr43dy;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor92979292pls.29.2019.08.03.02.19.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 02:19:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ptvr43dy;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=sTbQB+VsKCHhUtNcj2pWgbGTC92dmneZIV20ww0P/GA=;
        b=Ptvr43dyAwRTJFjdQ46Q5UJRR3WgPxjCpPpAjd6xGriBSCteIUzFlOoUWc3fCEvnKb
         fEcujK2zHXBktLD25UvZz5gWdJasFYke+5F2JdMBcyYwAQakJENftwGEvIUp2Dqc9JWE
         nJkcZP0uIRK51V8AWwdL7MizTSzBHXEX7hguvWSKMwAb3EB6Fm6K2ga7NznP7iwDrV+z
         F1aauptJ9+1ElBxHu7Iy4VbSxRatYSNJclwIjrs/U/Jp41zLs8pyXbofIN42ZBac4Vce
         K0TFDXuOzVW3/0olqO1xYOc4ntEoG69p9Avv4+UCv8k3tSquaN71AzLQsGFDuId7dIiP
         35GA==
X-Google-Smtp-Source: APXvYqx2Q+kPZ0ijXEICO0VwuKwto0+SwFiX/JVQedWqNZh5AXZETxTBQ+tGP7fFaB1yNQ3767o2mw==
X-Received: by 2002:a17:902:4643:: with SMTP id o61mr106674408pld.101.1564823998979;
        Sat, 03 Aug 2019 02:19:58 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id a3sm11758412pje.3.2019.08.03.02.19.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 02:19:58 -0700 (PDT)
Date: Sat, 3 Aug 2019 02:19:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Laura Abbott <labbott@redhat.com>
cc: Alexander Potapenko <glider@google.com>, 
    kernel test robot <rong.a.chen@intel.com>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>, 
    Masahiro Yamada <yamada.masahiro@socionext.com>, 
    "Serge E. Hallyn" <serge@hallyn.com>, 
    Nick Desaulniers <ndesaulniers@google.com>, 
    Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
    Sandeep Patil <sspatil@android.com>, Randy Dunlap <rdunlap@infradead.org>, 
    Jann Horn <jannh@google.com>, Mark Rutland <mark.rutland@arm.com>, 
    Marco Elver <elver@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: slub: Fix slab walking for init_on_free
In-Reply-To: <20190731193240.29477-1-labbott@redhat.com>
Message-ID: <alpine.DEB.2.21.1908030219420.112263@chino.kir.corp.google.com>
References:  <20190731193240.29477-1-labbott@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2019, Laura Abbott wrote:

> To properly clear the slab on free with slab_want_init_on_free,
> we walk the list of free objects using get_freepointer/set_freepointer.
> The value we get from get_freepointer may not be valid. This
> isn't an issue since an actual value will get written later
> but this means there's a chance of triggering a bug if we use
> this value with set_freepointer:
> 
> [    4.478342] kernel BUG at mm/slub.c:306!
> [    4.482437] invalid opcode: 0000 [#1] PREEMPT PTI
> [    4.485750] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-05754-g6471384a #4
> [    4.490635] RIP: 0010:kfree+0x58a/0x5c0
> [    4.493679] Code: 48 83 05 78 37 51 02 01 0f 0b 48 83 05 7e 37 51 02 01 48 83 05 7e 37 51 02 01 48 83 05 7e 37 51 02 01 48 83 05 d6 37 51 02 01 <0f> 0b 48 83 05 d4 37 51 02 01 48 83 05 d4 37 51 02 01 48 83 05 d4
> [    4.506827] RSP: 0000:ffffffff82603d90 EFLAGS: 00010002
> [    4.510475] RAX: ffff8c3976c04320 RBX: ffff8c3976c04300 RCX: 0000000000000000
> [    4.515420] RDX: ffff8c3976c04300 RSI: 0000000000000000 RDI: ffff8c3976c04320
> [    4.520331] RBP: ffffffff82603db8 R08: 0000000000000000 R09: 0000000000000000
> [    4.525288] R10: ffff8c3976c04320 R11: ffffffff8289e1e0 R12: ffffd52cc8db0100
> [    4.530180] R13: ffff8c3976c01a00 R14: ffffffff810f10d4 R15: ffff8c3976c04300
> [    4.535079] FS:  0000000000000000(0000) GS:ffffffff8266b000(0000) knlGS:0000000000000000
> [    4.540628] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    4.544593] CR2: ffff8c397ffff000 CR3: 0000000125020000 CR4: 00000000000406b0
> [    4.549558] Call Trace:
> [    4.551266]  apply_wqattrs_prepare+0x154/0x280
> [    4.554357]  apply_workqueue_attrs_locked+0x4e/0xe0
> [    4.557728]  apply_workqueue_attrs+0x36/0x60
> [    4.560654]  alloc_workqueue+0x25a/0x6d0
> [    4.563381]  ? kmem_cache_alloc_trace+0x1e3/0x500
> [    4.566628]  ? __mutex_unlock_slowpath+0x44/0x3f0
> [    4.569875]  workqueue_init_early+0x246/0x348
> [    4.573025]  start_kernel+0x3c7/0x7ec
> [    4.575558]  x86_64_start_reservations+0x40/0x49
> [    4.578738]  x86_64_start_kernel+0xda/0xe4
> [    4.581600]  secondary_startup_64+0xb6/0xc0
> [    4.584473] Modules linked in:
> [    4.586620] ---[ end trace f67eb9af4d8d492b ]---
> 
> Fix this by ensuring the value we set with set_freepointer is either NULL
> or another value in the chain.
> 
> Reported-by: kernel test robot <rong.a.chen@intel.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

