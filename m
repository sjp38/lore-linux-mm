Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25DB46B026E
	for <linux-mm@kvack.org>; Mon, 21 May 2018 02:44:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k1-v6so4052560pgq.20
        for <linux-mm@kvack.org>; Sun, 20 May 2018 23:44:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 70-v6si14179952pfu.274.2018.05.20.23.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 23:44:28 -0700 (PDT)
Subject: Patch "x86/pkeys: Do not special case protection key 0" has been added to the 4.9-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 21 May 2018 08:42:35 +0200
Message-ID: <1526884955235104@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 1522112702-27853-1-git-send-email-linuxram@us.ibm.com, 20180509171358.47FD785E@viggo.jf.intel.com, akpm@linux-foundation.org, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.orglinuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys: Do not special case protection key 0

to the 4.9-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-do-not-special-case-protection-key-0.patch
and it can be found in the queue-4.9 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
