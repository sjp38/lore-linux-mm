Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF276B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:12:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 33-v6so4591380wrb.12
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:12:31 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 187-v6si832105wms.146.2018.06.22.08.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 08:12:29 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 0/3] mm: use irq locking suffix instead local_irq_disable()
Date: Fri, 22 Jun 2018 17:12:18 +0200
Message-Id: <20180622151221.28167-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

small series which avoids using local_irq_disable()/local_irq_enable()
but instead does spin_lock_irq()/spin_unlock_irq() so it is within the
context of the lock which it belongs to.
Patch #1 is a cleanup where local_irq_.*() remained after the lock was
removed.

Sebastian
