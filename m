Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDBC8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 18:41:07 -0400 (EDT)
Subject: Patch "x86: Flush TLB if PGD entry is changed in i386 PAE mode" has been added to the 2.6.32-longterm tree
From: <gregkh@suse.de>
Date: Fri, 18 Mar 2011 15:40:28 -0700
Message-ID: <13004880282614@kroah.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shaohua.li@intel.com, 1300246649.2337.95.camel@sli10-conroe.kvack.org, akpm@linux-foundation.org, asit.k.mallick@intel.com, gregkh@suse.de, linux-mm@kvack.org, mingo@elte.hu, riel@redhat.com, torvalds@linux-foundation.org, y-goto@jp.fujitsu.com
Cc: stable@kernel.org, stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86: Flush TLB if PGD entry is changed in i386 PAE mode

to the 2.6.32-longterm tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/longterm/longterm-queue-2.6.32.git;a=summary

The filename of the patch is:
     x86-flush-tlb-if-pgd-entry-is-changed-in-i386-pae-mode.patch
and it can be found in the queue-2.6.32 subdirectory.

If you, or anyone else, feels it should not be added to the 2.6.32 longterm tree,
please let <stable@kernel.org> know about it.
