Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC1708E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 10:30:30 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y74so5330358wmc.0
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 07:30:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m3si4811248wrj.401.2018.12.19.07.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 19 Dec 2018 07:30:29 -0800 (PST)
Date: Wed, 19 Dec 2018 16:30:22 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181219153022.w5le6nf7meiogh72@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
 <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
 <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
 <16ac893a-a080-18a5-e636-7b7668d978b0@windriver.com>
 <20181218150744.GB20197@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20181218150744.GB20197@arrakis.emea.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: He Zhe <zhe.he@windriver.com>, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On 2018-12-18 15:07:45 [+0000], Catalin Marinas wrote:
=E2=80=A6
> It may be worth running some performance/latency tests during kmemleak
> scanning (echo scan > /sys/kernel/debug/kmemleak) but at a quick look,
> I don't think we'd see any difference with a raw_spin_lock_t.
>=20
> With a bit more thinking (though I'll be off until the new year), we
> could probably get rid of the kmemleak_lock entirely in scan_block() and
> make lookup_object() and the related rbtree code in kmemleak RCU-safe.

Okay. So let me apply that patch into my RT tree with your ack (from the
other email). And then I hope that it either shows up upstream or gets
replaced with RCU in the ende :)

Thanks.

Sebastian
