Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B34F36B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 16:04:30 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so75950239pfb.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 13:04:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l8si37942221pfb.18.2016.02.14.13.04.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 13:04:29 -0800 (PST)
Subject: Patch "sched: Fix crash in sched_init_numa()" has been added to the 4.3-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 14 Feb 2016 13:04:29 -0800
Message-ID: <1455483869147137@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghavendra.kt@linux.vnet.ibm.com, anton@samba.org, benh@kernel.crashing.org, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, gregkh@linuxfoundation.org, jstancek@redhat.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, mingo@kernel.org, mpe@ellerman.id.au, nikunj@linux.vnet.ibm.com, paulus@samba.org, peterz@infradead.org, vdavydov@parallels.com
Cc: stable@vger.kernel.org, stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    sched: Fix crash in sched_init_numa()

to the 4.3-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     sched-fix-crash-in-sched_init_numa.patch
and it can be found in the queue-4.3 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
