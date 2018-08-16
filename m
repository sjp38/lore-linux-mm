Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10D6A6B02AE
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:03:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i68-v6so2378357pfb.9
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:03:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a12-v6si2091954pgv.680.2018.08.16.10.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 10:03:54 -0700 (PDT)
Subject: Patch "x86/mm: Add TLB purge to free pmd/pte page interfaces" has been added to the 4.18-stable tree
From: <gregkh@linuxfoundation.org>
Date: Thu, 16 Aug 2018 19:01:58 +0200
Message-ID: <15344389188812@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180627141348.21777-4-toshi.kani@hpe.com, akpm@linux-foundation.org, cpandya@codeaurora.org, gregkh@linuxfoundation.org, hpa@zytor.com, joro@8bytes.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, mhocko@suse.com, tglx@linutronix.detoshi.kani@hpe.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Add TLB purge to free pmd/pte page interfaces

to the 4.18-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-add-tlb-purge-to-free-pmd-pte-page-interfaces.patch
and it can be found in the queue-4.18 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
