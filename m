Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28A046B000C
	for <linux-mm@kvack.org>; Mon, 21 May 2018 02:42:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d20-v6so8691384pfn.16
        for <linux-mm@kvack.org>; Sun, 20 May 2018 23:42:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p33-v6si13444007pld.318.2018.05.20.23.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 23:42:27 -0700 (PDT)
Subject: Patch "x86/pkeys: Override pkey when moving away from PROT_EXEC" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 21 May 2018 08:41:29 +0200
Message-ID: <152688488911097@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171351.084C5A71@viggo.jf.intel.com, akpm@linux-foundation.org, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shakeelb@google.com, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys: Override pkey when moving away from PROT_EXEC

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-override-pkey-when-moving-away-from-prot_exec.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
