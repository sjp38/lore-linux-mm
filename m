Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A45B6B026F
	for <linux-mm@kvack.org>; Mon, 21 May 2018 02:44:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so9523259plb.20
        for <linux-mm@kvack.org>; Sun, 20 May 2018 23:44:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s14-v6si10381431pgf.263.2018.05.20.23.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 23:44:32 -0700 (PDT)
Subject: Patch "x86/pkeys: Override pkey when moving away from PROT_EXEC" has been added to the 4.9-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 21 May 2018 08:42:35 +0200
Message-ID: <152688495526206@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171351.084C5A71@viggo.jf.intel.com, akpm@linux-foundation.org, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shakeelb@google.com, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys: Override pkey when moving away from PROT_EXEC

to the 4.9-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-override-pkey-when-moving-away-from-prot_exec.patch
and it can be found in the queue-4.9 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
