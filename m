Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37806B02AA
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:03:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g26-v6so2364140pfo.7
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:03:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u64-v6si26901402pgu.533.2018.08.16.10.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 10:03:06 -0700 (PDT)
Subject: Patch "x86/mm: Add TLB purge to free pmd/pte page interfaces" has been added to the 4.17-stable tree
From: <gregkh@linuxfoundation.org>
Date: Thu, 16 Aug 2018 19:01:39 +0200
Message-ID: <153443889914125@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180627141348.21777-4-toshi.kani@hpe.com, akpm@linux-foundation.org, cpandya@codeaurora.org, gregkh@linuxfoundation.org, hpa@zytor.com, joro@8bytes.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, mhocko@suse.com, tglx@linutronix.detoshi.kani@hpe.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Add TLB purge to free pmd/pte page interfaces

to the 4.17-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-add-tlb-purge-to-free-pmd-pte-page-interfaces.patch
and it can be found in the queue-4.17 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
