Received: from localhost (localhost [127.0.0.1])
	by baldur.austin.ibm.com (8.12.9/8.12.9/Debian-3) with ESMTP id h4SMA6FA024590
	for <linux-mm@kvack.org>; Wed, 28 May 2003 17:10:07 -0500
Date: Wed, 28 May 2003 17:10:06 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Question about locking in mmap.c
Message-ID: <133810000.1054159806@baldur.austin.ibm.com>
In-Reply-To: <33460000.1054135672@baldur.austin.ibm.com>
References: <33460000.1054135672@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, May 28, 2003 10:27:52 -0500 Dave McCracken
<dmccr@us.ibm.com> wrote:

> My question is what is page_table_lock supposed to be protecting against?
> Am I wrong that mmap_sem is sufficient to protect against concurrent
> changes to the vmas?

I decided one way to find out was to remove the page_table_lock from mmap.
I discovered one place it protects against is vmtruncate(), so it's
definitely needed as it stands.  I got an oops in zap_page_range() called
from vmtruncate().

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
