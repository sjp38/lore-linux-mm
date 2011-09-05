Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 209776B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 05:14:46 -0400 (EDT)
Received: by vxj3 with SMTP id 3so4942416vxj.14
        for <linux-mm@kvack.org>; Mon, 05 Sep 2011 02:14:43 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 5 Sep 2011 14:44:43 +0530
Message-ID: <CAFPAmTTaq2Lz=eGgfG2-5U0M9aS_aZLNAANAVPZj6TEo9EdjGg@mail.gmail.com>
Subject: Is there any way to stop reclamation of file cache pages ?
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-fsdev@vger.rutgers.edu
Cc: linux-kernel@vger.kernel.org

Hi,

I am aware that mlocked pages can be stopped from being reclaimed
through the PFRA.

However, is there any method to stop reclamation of the page-cache
pages pertaining to
a single file's inode without mlocking ?

If I want to only use the open, read and write system calls and I want
to set specific file cache
pages to "non-reclaimable", how can I do so ?

Will the POSIX_FADV_WILLNEED option to the fadvise() system call solve
this problem ?

Thanks,
Kautuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
