Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9BC6B395C
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 02:17:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g9-v6so8732908pgc.16
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 23:17:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w66-v6si12671491pfi.88.2018.08.25.23.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Aug 2018 23:17:57 -0700 (PDT)
Subject: Patch "x86/mm: Fix use-after-free of ldt_struct" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 26 Aug 2018 08:17:38 +0200
Message-ID: <1535264258387@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20170824175029.76040-1-ebiggers3@gmail.com, akpm@linux-foundation.org, ben.hutchings@codethink.co.uk, bp@alien8.de, brgerst@gmail.com, dave.hansen@linux.intel.com, dvlasenk@redhat.com, dvyukov@google.com, ebiggers@google.com, gregkh@linuxfoundation.org, hch@lst.de, linux-mm@kvack.org, luto@amacapital.net, mhocko@suse.com, mingo@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, riel@redhat.com, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Fix use-after-free of ldt_struct

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-fix-use-after-free-of-ldt_struct.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
