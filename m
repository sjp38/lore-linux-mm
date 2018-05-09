Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE8F6B056C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:37:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e15-v6so59938wmh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:37:04 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s62si8378012wmf.190.2018.05.09.12.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:37:03 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH v2 0/8] Introduce refcount_dec_and_lock_irqsave()
Date: Wed,  9 May 2018 21:36:37 +0200
Message-Id: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

This series is a v2 of the atomic_dec_and_lock_irqsave(). Now refcount_*
is used instead of atomic_* as suggested by Peter Zijlstra.

Patch
- 1-3 converts the user from atomic_* API to refcount_* API
- 4 implements refcount_dec_and_lock_irqsave
- 5-8 converts the local_irq_save() + refcount_dec_and_lock() users to
  refcount_dec_and_lock_irqsave()

The whole series sits also at
  git://git.kernel.org/pub/scm/linux/kernel/git/bigeasy/staging.git refcoun=
t_t_irqsave

Sebastian
