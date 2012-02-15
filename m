Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 416CC6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 13:33:22 -0500 (EST)
Date: Wed, 15 Feb 2012 13:33:18 -0500
From: Dave Jones <davej@redhat.com>
Subject: exit_mmap() BUG_ON triggering since 3.1
Message-ID: <20120215183317.GA26977@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Fedora Kernel Team <kernel-team@fedoraproject.org>

We've had three reports against the Fedora kernel recently where
a process exits, and we're tripping up the 

        BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);

in exit_mmap()

It started happening with 3.1, but still occurs on 3.2
(no 3.3rc reports yet, but it's not getting much testing).

https://bugzilla.redhat.com/show_bug.cgi?id=786632
https://bugzilla.redhat.com/show_bug.cgi?id=787527
https://bugzilla.redhat.com/show_bug.cgi?id=790546

I don't see anything special in common between the loaded modules.

anyone?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
