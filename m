Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BF39D6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 19:49:00 -0400 (EDT)
Date: Mon, 23 May 2011 16:48:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 35662] New: softlockup with kernel 2.6.39
Message-Id: <20110523164804.572cecfd.akpm@linux-foundation.org>
In-Reply-To: <201105240241.52307.hussam@visp.net.lb>
References: <bug-35662-10286@https.bugzilla.kernel.org/>
	<20110523162225.6017b2df.akpm@linux-foundation.org>
	<201105240241.52307.hussam@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hussam Al-Tayeb <ht990332@gmail.com>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org

On Tue, 24 May 2011 02:41:51 +0300
Hussam Al-Tayeb <ht990332@gmail.com> wrote:

> YEs, 
> lsmod | grep dm_crypt
> dm_crypt               12887  2 
> dm_mod                 55464  5 dm_crypt
> 
> Still no lockups since downgrading to 2.6.38.6 which was a few hours before I 
> filed the bug report.
> I could reinstall 2.6.39 if there is anything you would like me to test.

Thanks.

CONFIG_PROVE_LOCKING=y would be useful, if you didn't already have it
set.

Also after the kernel has failed, kill everything off and do a `ps aux'
and look for any other tasks which are stuck in "D" state.  Backtraces
for any such processes can be obtained with "echo w >
/proc/sysrq-trigger".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
