Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD608D003A
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:50:35 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH v1 0/6] Set printk priority level
Date: Wed, 26 Jan 2011 15:29:24 -0800
Message-Id: <1296084570-31453-1-git-send-email-msb@chromium.org>
In-Reply-To: <20110125235700.GR8008@google.com>
References: <20110125235700.GR8008@google.com>
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We've been burned by regressions/bugs which we later realized could
have been triaged quicker if only we'd paid closer attention to
dmesg.

This patch series fixes printk()s which appear in the logs of the
device I'm currently working on. I'd love to fix all such printks
but there are hundreds of files and thousands of LOC affected:

$ find . -name \*.c | xargs fgrep -c "printk(\"" | wc -l
16237
$ find . -name \*.c | xargs fgrep "printk(\"" | wc -l
20745

[PATCH 1/6] mm/page_alloc: use appropriate printk priority level
[PATCH 2/6] arch/x86: use appropriate printk priority level
[PATCH 3/6] PM: use appropriate printk priority level
[PATCH 4/6] TTY: use appropriate printk priority level
[PATCH 5/6] fs: use appropriate printk priority level
[PATCH 6/6] taskstats: use appropriate printk priority level

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
