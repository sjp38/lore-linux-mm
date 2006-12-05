Received: from ms-mss-01 (ms-mss-01-smtp.texas.rr.com [10.93.38.14])
	by ms-smtp-04.texas.rr.com (8.13.6/8.13.6) with ESMTP id kB5KdDke028617
	for <linux-mm@kvack.org>; Tue, 5 Dec 2006 14:39:13 -0600 (CST)
Received: from texas.rr.com (localhost [127.0.0.1]) by ms-mss-01.texas.rr.com
 (iPlanet Messaging Server 5.2 HotFix 2.10 (built Dec 26 2005))
 with ESMTP id <0J9T00C9BIPDIC@ms-mss-01.texas.rr.com> for linux-mm@kvack.org;
 Tue, 05 Dec 2006 14:39:13 -0600 (CST)
Date: Tue, 05 Dec 2006 14:39:13 -0600
From: aucoin@houston.rr.com
Subject: Re: la la la la ... swappiness
In-reply-to: <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
Message-id: <d08091ab21581.21581d08091ab@texas.rr.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: en
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
 <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com>
 <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
Sender: owner-linux-mm@kvack.org
From: Linus Torvalds <torvalds@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I didn't post it yet, I don't have a recent build with oom enabled at
the moment so I was digging through old bugzillas to see what I could
find. Here are some pieces from one oom firing, they're from old runs
and based on the bugzilla context I can't swear it's exactly the same
problem, I'm looking for more. The "ae" process that's being kill is one
of the three processes attached to the 1.6G shm.

Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c01049a4>] show_trace+0xd/0xf
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c0104a43>] dump_stack+0x17/0x19
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c0138f44>] out_of_memory+0x27/0x12f
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c013a617>] __alloc_pages+0x1e1/0x261
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c013a6bf>] __get_free_pages+0x28/0x37
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c015f066>] __pollwait+0x33/0x9e
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c01eb25c>] mqueue_poll_file+0x27/0x57
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c015fb9b>] do_sys_poll+0x165/0x2da
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c015ff24>] sys_poll+0x43/0x47
Oct 11 19:06:38 QAR2MOVDB2 kernel:  [<c0103513>] sysenter_past_esp+0x54/0x75

Oct 11 19:08:19 QAR2MOVDB2 kernel: Free swap  = 421008kB
Oct 11 19:08:19 QAR2MOVDB2 kernel: Total swap = 524276kB
Oct 11 19:08:19 QAR2MOVDB2 kernel: Free swap:       421008kB
Oct 11 19:08:19 QAR2MOVDB2 kernel: 524224 pages of RAM
Oct 11 19:08:19 QAR2MOVDB2 kernel: 294848 pages of HIGHMEM
Oct 11 19:08:19 QAR2MOVDB2 kernel: 5437 reserved pages
Oct 11 19:08:19 QAR2MOVDB2 kernel: 1340645 pages shared
Oct 11 19:08:19 QAR2MOVDB2 kernel: 25817 pages swap cached
Oct 11 19:08:19 QAR2MOVDB2 kernel: 107 pages dirty
Oct 11 19:08:19 QAR2MOVDB2 kernel: 45405 pages writeback
Oct 11 19:08:19 QAR2MOVDB2 kernel: 2638 pages mapped
Oct 11 19:08:19 QAR2MOVDB2 kernel: 29632 pages slab
Oct 11 19:08:19 QAR2MOVDB2 kernel: 385 pages pagetables
Oct 11 19:08:19 QAR2MOVDB2 kernel: Out of Memory: Kill process 1636 (ae)
score
556471 and children.
Oct 11 19:08:19 QAR2MOVDB2 kernel: Out of memory: Killed process 1636 (ae).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
