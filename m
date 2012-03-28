Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8FF2F6B004D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 15:38:02 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2744172pbc.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2012 12:38:01 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 28 Mar 2012 12:37:41 -0700
Message-ID: <CALCETrXeVgh4LuLmCCiHXohX8Vd_SJbo-h1r_wywTxLs6q+tjw@mail.gmail.com>
Subject: Unexpected swapping without memory pressure
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Last night, a server I run did something very strange: it swapped out
a bunch of pages when it apparently had lots of free memory.  This
same server has had a more or less identical load for weeks and hasn't
swapped.  Munin says:

http://web.mit.edu/luto/www/kernel/memory-day.png
http://web.mit.edu/luto/www/kernel/swap-day.png

When this happened, free memory was high.  Any ideas?

This is a mainline kernel 3.0.19 with very minor and non-mm-related patches.

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
