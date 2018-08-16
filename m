Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 031E16B000D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 07:57:46 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id v15-v6so2605734ply.20
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 04:57:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r28-v6si25858361pgk.458.2018.08.16.04.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 04:57:44 -0700 (PDT)
Subject: Patch "x86/mm: Disable ioremap free page handling on x86-PAE" has been added to the 4.18-stable tree
From: <gregkh@linuxfoundation.org>
Date: Thu, 16 Aug 2018 13:57:33 +0200
Message-ID: <1534420653141123@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180627141348.21777-2-toshi.kani@hpe.com, akpm@linux-foundation.org, cpandya@codeaurora.org, gregkh@linuxfoundation.org, hpa@zytor.com, joro@8bytes.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, mhocko@suse.com, tglx@linutronix.detoshi.kani@hpe.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Disable ioremap free page handling on x86-PAE

to the 4.18-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-disable-ioremap-free-page-handling-on-x86-pae.patch
and it can be found in the queue-4.18 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
