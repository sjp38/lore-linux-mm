Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 076F96B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:52:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g9-v6so1096597wrq.7
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:52:46 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z14-v6si1124798wru.344.2018.07.03.07.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 07:52:45 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: 
Date: Tue,  3 Jul 2018 16:52:31 +0200
Message-Id: <20180703145235.28050-1-bigeasy@linutronix.de>
In-Reply-To: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
References: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
Reply-To: "[PATCH 0/4]"@kvack.org, "mm/list_lru:add"@kvack.org,
	list_lru_shrink_walk_irq@kvack.org, and@kvack.org (), use@kvack.org,
	it@kvack.org
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

My intepretation of situtation is that Vladimir Davydon is fine patch #1
and #2 of the series [0] but dislikes the irq argument and struct
member. It has been suggested to use list_lru_shrink_walk_irq() instead
the approach I went on in "mm: list_lru: Add lock_irq member to
__list_lru_init()".

This series is based on the former two patches and introduces
list_lru_shrink_walk_irq() (and makes the third patch of series
obsolete).
In patch 1-3 I tried a tiny cleanup so the different locking
(spin_lock() vs spin_lock_irq()) is simply lifted to the caller of the
function.

[0] The patch
      mm: workingset: remove local_irq_disable() from count_shadow_nodes()=
=20
   and
      mm: workingset: make shadow_lru_isolate() use locking suffix

Sebastian
