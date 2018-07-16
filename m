Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 172836B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:19:33 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g9-v6so8278724wrq.7
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:19:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w15-v6si23318806wrg.306.2018.07.16.04.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 04:19:31 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 0/4] mm/list_lru: Add list_lru_shrink_walk_irq() and a user
Date: Mon, 16 Jul 2018 13:19:17 +0200
Message-Id: <20180716111921.5365-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

This series removes the local_irq_disable() around
list_lru_shrink_walk() (as used by mm/workingset) by adding
list_lru_shrink_walk_irq(). Vladimir Davydov preferred this over an `irq'
argument which I added to struct list_lru.

The initial post (of this series) received a Reviewed-by tag by Vladimir
Davydov which I added to each patch of the series.
The series applies on top of akpm's tree which has Kirill's shrink_slab
series and does not clash with it (akpm asked me to wait a week or so
and repost it then).

I tested the code paths by triggering the OOM-killer via memory over
commit and lockdep did not complain (nor did I see any warnings).

Sebastian

Sebastian
