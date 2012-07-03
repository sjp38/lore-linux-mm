Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 28C4E6B0072
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 23:07:12 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 21:07:11 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B59AC19D8048
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 03:07:08 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6336Mtt109316
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 21:06:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q63366wK021720
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 21:06:06 -0600
Received: from shangw ([9.125.29.66])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q63366Db021702
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 21:06:06 -0600
Date: Tue, 3 Jul 2012 11:06:05 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [Question] how to avoid process hang without disk space
Message-ID: <20120703030605.GA30077@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Recently, we're encountering one problem that caused by full disk drives.
I'm not sure if there has any method to recover from the situation?

When the problem happened, I couldn't kill the process with signal 9.
Also, the "reboot" would cause system hang as well.

Here's the backtrace from kernel.
=================================

INFO: task jbd2/dm-0-8:463 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
jbd2/dm-0-8   D 0000000000000000     0   463      2 0x00008000
Call Trace:
[c0000006ef23f190] [c0000006ef23f240] 0xc0000006ef23f240 (unreliable)
[c0000006ef23f360] [c000000000014288] .__switch_to+0xf8/0x1d0
[c0000006ef23f3f0] [c00000000059cc18] .schedule+0x408/0xd30
[c0000006ef23f6d0] [c00000000059d5d0] .io_schedule+0x90/0x110
[c0000006ef23f760] [c00000000014c5a0] .sync_page+0x70/0xa0
[c0000006ef23f7e0] [c00000000059dee4] .__wait_on_bit_lock+0xd4/0x1b0
[c0000006ef23f8a0] [c00000000014c4e4] .__lock_page+0x54/0x70
[c0000006ef23f960] [c0000000001680bc] .write_cache_pages+0x3fc/0x4a0
[c0000006ef23fb10] [d000000004fb3384] .journal_submit_inode_data_buffers+0x64/0x90 [jbd2]
[c0000006ef23fc20] [d000000004fb3a1c] .jbd2_journal_commit_transaction+0x44c/0x1940 [jbd2]
[c0000006ef23fde0] [d000000004fbc2fc] .kjournald2+0xec/0x300 [jbd2]
[c0000006ef23fed0] [c0000000000bb02c] .kthread+0xbc/0xd0
[c0000006ef23ff90] [c0000000000323f4] .kernel_thread+0x54/0x70

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
