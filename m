Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 683336B1D0D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 01:28:55 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id v9-v6so4920238ply.13
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 22:28:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c192-v6si11709348pfg.347.2018.08.20.22.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 22:28:54 -0700 (PDT)
Subject: Patch "x86/mm: Simplify p[g4um]d_page() macros" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Tue, 21 Aug 2018 07:28:23 +0200
Message-ID: <153482930314579@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, arnd@arndb.de, aryabinin@virtuozzo.com, bp@alien8.de, bp@suse.de, brijesh.singh@amd.com, corbet@lwn.net, dvyukov@google.com, dyoung@redhat.com, e61eb533a6d0aac941db2723d8aa63ef6b882dee.1500319216.git.thomas.lendacky@amd.com, glider@google.com, gregkh@linuxfoundation.org, kasan-dev@googlegroups.com, konrad.wilk@oracle.com, linux-mm@kvack.org, luto@kernel.org, lwoodman@redhat.com, matt@codeblueprint.co.uk, mingo@kernel.org, mst@redhat.com, pbonzini@redhat.com, peterz@infradead.org, riel@redhat.com, rkrcmar@redhat.com, tglx@linutronix.dethomas.lendacky@amd.com, torvalds@linux-foundation.org, toshi.kani@hpe.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Simplify p[g4um]d_page() macros

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-simplify-pd_page-macros.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
