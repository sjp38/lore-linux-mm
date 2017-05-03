Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFB896B02F2
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:45:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f96so7664942qki.14
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:45:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y125si2397118qkd.200.2017.05.03.11.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:45:05 -0700 (PDT)
Message-Id: <20170503184007.174707977@redhat.com>
Date: Wed, 03 May 2017 15:40:07 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [patch 0/3] per-CPU vmstat thresholds and vmstat worker disablement (v2)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

The per-CPU vmstat worker is a problem on -RT workloads (because
ideally the CPU is entirely reserved for the -RT app, without
interference). The worker transfers accumulated per-CPU
vmstat counters to global counters.

To resolve the problem, create two tunables:

* Userspace configurable per-CPU vmstat threshold: by default the
VM code calculates the size of the per-CPU vmstat arrays. This
tunable allows userspace to configure the values.

* Userspace configurable per-CPU vmstat worker: allow disabling
the per-CPU vmstat worker.

v2:
- Improve documentation (Rik/Luiz).
- Split patch in two (Luiz).
- Fix comparison to include equal, in the helpers for
stats accounting.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
