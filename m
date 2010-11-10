Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DF0276B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 10:25:24 -0500 (EST)
Date: Wed, 10 Nov 2010 16:25:19 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: BUG: Bad page state in process (current git)
Message-ID: <20101110152519.GA1626@arch.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This happend twice in the last 24h on my machine:

Nov  9 20:29:42 arch kernel: BUG: Bad page state in process mutt  pfn:a6869
Nov  9 20:29:42 arch kernel: page:ffffea000246d6f8 count:0 mapcount:0 mapping:          (null) index:0x0
Nov  9 20:29:42 arch kernel: page flags: 0x4000000000000008(uptodate)
Nov  9 20:29:42 arch kernel: Pid: 1794, comm: mutt Not tainted 2.6.37-rc1-00168-gb369291-dirty #72
Nov  9 20:29:42 arch kernel: Call Trace:
Nov  9 20:29:42 arch kernel: [<ffffffff810a1d32>] ? bad_page+0x92/0xe0
Nov  9 20:29:42 arch kernel: [<ffffffff810a2f50>] ? get_page_from_freelist+0x4b0/0x570
Nov  9 20:29:42 arch kernel: [<ffffffff810a3123>] ? __alloc_pages_nodemask+0x113/0x6b0
Nov  9 20:29:42 arch kernel: [<ffffffff8109c5f4>] ? find_get_page+0x64/0xb0
Nov  9 20:29:42 arch kernel: [<ffffffff8109c858>] ? filemap_fault+0x98/0x4b0
Nov  9 20:29:42 arch kernel: [<ffffffff811807ec>] ? cpumask_any_but+0x2c/0x40
Nov  9 20:29:42 arch kernel: [<ffffffff810b4acc>] ? do_wp_page+0xbc/0x7e0
Nov  9 20:29:42 arch kernel: [<ffffffff810b6ab3>] ? handle_mm_fault+0x4e3/0x970
Nov  9 20:29:42 arch kernel: [<ffffffff8104b1d0>] ? do_page_fault+0x120/0x410
Nov  9 20:29:42 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
Nov  9 20:29:42 arch kernel: [<ffffffff8118a09d>] ? __put_user_4+0x1d/0x30
Nov  9 20:29:42 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
Nov  9 20:29:42 arch kernel: Disabling lock debugging due to kernel taint


Nov 10 14:35:25 arch kernel: BUG: Bad page state in process firefox-bin  pfn:a049d
Nov 10 14:35:25 arch kernel: page:ffffea0002310258 count:0 mapcount:0 mapping:          (null) index:0x0
Nov 10 14:35:25 arch kernel: page flags: 0x4000000000000008(uptodate)
Nov 10 14:35:25 arch kernel: Pid: 23080, comm: firefox-bin Not tainted 2.6.37-rc1-00168-gb369291-dirty #72
Nov 10 14:35:25 arch kernel: Call Trace:
Nov 10 14:35:25 arch kernel: [<ffffffff810a1d32>] ? bad_page+0x92/0xe0
Nov 10 14:35:25 arch kernel: [<ffffffff810a2f50>] ? get_page_from_freelist+0x4b0/0x570
Nov 10 14:35:25 arch kernel: [<ffffffff8105325c>] ? enqueue_task_fair+0x14c/0x190
Nov 10 14:35:25 arch kernel: [<ffffffff810a3123>] ? __alloc_pages_nodemask+0x113/0x6b0
Nov 10 14:35:25 arch kernel: [<ffffffff8109bb04>] ? file_read_actor+0xc4/0x190
Nov 10 14:35:25 arch kernel: [<ffffffff8109d788>] ? generic_file_aio_read+0x558/0x6a0
Nov 10 14:35:25 arch kernel: [<ffffffff810b6c8d>] ? handle_mm_fault+0x6bd/0x970
Nov 10 14:35:25 arch kernel: [<ffffffff810cda2f>] ? do_sync_read+0xbf/0x100
Nov 10 14:35:25 arch kernel: [<ffffffff8104b1d0>] ? do_page_fault+0x120/0x410
Nov 10 14:35:25 arch kernel: [<ffffffff810bbf7f>] ? mmap_region+0x1df/0x4b0
Nov 10 14:35:25 arch kernel: [<ffffffff81448295>] ? schedule+0x285/0x850
Nov 10 14:35:25 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
Nov 10 14:35:25 arch kernel: Disabling lock debugging due to kernel taint

My memory is fine as far as I can tell (memtest and a linpack stress
test ran without errors).
Any ideas on what might be going on?

(The dirty flag is due to this patch: https://patchwork.kernel.org/patch/311202/)
-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
