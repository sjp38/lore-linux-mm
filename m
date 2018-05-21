Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 921CB6B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 02:42:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t5-v6so9538566ply.13
        for <linux-mm@kvack.org>; Sun, 20 May 2018 23:42:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a123-v6si10602656pgc.597.2018.05.20.23.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 23:42:21 -0700 (PDT)
Subject: Patch "x86/mm: Drop TS_COMPAT on 64-bit exec() syscall" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 21 May 2018 08:41:28 +0200
Message-ID: <15268848885988@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 0x7f454c46@gmail.com, 20180517233510.24996-1-dima@arista.com, amonakov@ispras.ru, bp@suse.dedima@arista.com, gorcunov@openvz.org, gregkh@linuxfoundation.org, hpa@zytor.com, izbyshev@ispras.ru, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, luto@kernel.org, tglx@linutronix.de
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Drop TS_COMPAT on 64-bit exec() syscall

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-drop-ts_compat-on-64-bit-exec-syscall.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
