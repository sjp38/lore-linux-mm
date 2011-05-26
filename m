Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5A26B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 12:34:00 -0400 (EDT)
Received: by wyf19 with SMTP id 19so852820wyf.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 09:33:57 -0700 (PDT)
From: Hussam Al-Tayeb <ht990332@gmail.com>
Subject: Re: [Bugme-new] [Bug 35662] New: softlockup with kernel 2.6.39
Date: Thu, 26 May 2011 19:33:48 +0300
References: <bug-35662-10286@https.bugzilla.kernel.org/> <20110523164804.572cecfd.akpm@linux-foundation.org> <201105241001.47111.hussam@visp.net.lb>
In-Reply-To: <201105241001.47111.hussam@visp.net.lb>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201105261933.48895.hussam@visp.net.lb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hussam Al-Tayeb <ht990332@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org

Another time.

[ 8520.275830] INFO: task khugepaged:26 blocked for more than 120 seconds.
[ 8520.275834] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
this message.
[ 8520.275837] khugepaged      D c1455200     0    26      2 0x00000000
[ 8520.275843]  f3f9fedc 00000046 f59af000 c1455200 00000400 c1455200 c1455580 
f3c451f0
[ 8520.275850]  0000000a f3f9fe88 c10c5078 c1455c80 00000003 f5506380 c14c4380 
f3c451f0
[ 8520.275857]  f3c453b4 33c86581 0000069a c14c4380 f5506380 f3c451f0 c4525640 
f3f9fee8
[ 8520.275864] Call Trace:
[ 8520.275874]  [<c10c5078>] ? __alloc_pages_direct_compact+0xe8/0x160
[ 8520.275880]  [<c10ff3f8>] ? __mem_cgroup_try_charge+0x2d8/0x4e0
[ 8520.275885]  [<c10fd138>] ? memcg_check_events+0x28/0x160
[ 8520.275891]  [<c131b885>] rwsem_down_failed_common+0x95/0xe0
[ 8520.275895]  [<c131b8e2>] rwsem_down_write_failed+0x12/0x20
[ 8520.275900]  [<c131b94a>] call_rwsem_down_write_failed+0x6/0x8
[ 8520.275904]  [<c131b0f5>] ? down_write+0x15/0x17
[ 8520.275908]  [<c10f8c72>] khugepaged+0x552/0xdf0
[ 8520.275913]  [<c10613a0>] ? autoremove_wake_function+0x0/0x40
[ 8520.275922]  [<c10f8720>] ? khugepaged+0x0/0xdf0
[ 8520.275924]  [<c1060d08>] kthread+0x68/0x70
[ 8520.275926]  [<c1060ca0>] ? kthread+0x0/0x70
[ 8520.275929]  [<c1003d7e>] kernel_thread_helper+0x6/0x18

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
