Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9327D6B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:27:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k8so5414856wrg.18
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 02:27:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i52si7536055wrf.497.2018.02.20.02.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 02:27:02 -0800 (PST)
Subject: Patch "x86/mm: Rename flush_tlb_single() and flush_tlb_one() to __flush_tlb_one_[user|kernel]()" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Tue, 20 Feb 2018 11:26:08 +0100
Message-ID: <15191223689933@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: luto@kernel.org, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, dave.hansen@intel.com, eduval@amazon.com, gregkh@linuxfoundation.org, hughd@google.com, jgross@suse.com, jpoimboe@redhat.com, keescook@google.com, linux-mm@kvack.org, mingo@kernel.org, peterz@infradead.org, riel@redhat.com, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com
Cc: stable@vger.kernel.org, stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Rename flush_tlb_single() and flush_tlb_one() to __flush_tlb_one_[user|kernel]()

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-rename-flush_tlb_single-and-flush_tlb_one-to-__flush_tlb_one_.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
