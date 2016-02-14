Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CE33E6B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 16:12:52 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so75282445pac.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 13:12:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p71si37971394pfi.128.2016.02.14.13.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 13:12:52 -0800 (PST)
Subject: Patch "sched: Fix crash in sched_init_numa()" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 14 Feb 2016 13:12:51 -0800
Message-ID: <1455484371152114@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghavendra.kt@linux.vnet.ibm.com, anton@samba.org, benh@kernel.crashing.org, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, gregkh@linuxfoundation.org, jstancek@redhat.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, mingo@kernel.org, mpe@ellerman.id.au, nikunj@linux.vnet.ibm.com, paulus@samba.org, peterz@infradead.org, vdavydov@parallels.com
Cc: stable@vger.kernel.org, stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    sched: Fix crash in sched_init_numa()

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     sched-fix-crash-in-sched_init_numa.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
