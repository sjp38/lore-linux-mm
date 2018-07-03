Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 319B66B000D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:02:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n8-v6so1265849wmh.0
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:02:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c4-v6si1397522wro.419.2018.07.03.13.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 13:02:01 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 0/6] use irqsafe variant of refcount_dec_and_lock() / atomic_dec_and_lock()
Date: Tue,  3 Jul 2018 22:01:35 +0200
Message-Id: <20180703200141.28415-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

The irqsave variant of refcount_dec_and_lock() and atomic_dec_and_lock()
made it into v4.18-rc2. This is just a repost of the users so that they
can be routed through the individual subsystems.
=20
Sebastian
=20
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
