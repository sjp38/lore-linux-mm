Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 585496B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:45:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n17-v6so1091475wmc.8
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:45:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l10-v6si3498618wra.436.2018.05.04.08.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 08:45:47 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Introduce atomic_dec_and_lock_irqsave()
Date: Fri,  4 May 2018 17:45:28 +0200
Message-Id: <20180504154533.8833-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

This series introduces atomic_dec_and_lock_irqsave() and converts a few
users to use it. They were using local_irq_save() +
atomic_dec_and_lock() before that series.

Sebastian
