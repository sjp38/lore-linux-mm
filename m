Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBD456B033C
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:00:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id j130so49779762qkj.3
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:00:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h132si8333201qka.56.2017.04.25.07.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 07:00:29 -0700 (PDT)
Message-Id: <20170425135717.375295031@redhat.com>
Date: Tue, 25 Apr 2017 10:57:17 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [patch 0/2] per-CPU vmstat thresholds and vmstat worker disablement
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




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
