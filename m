Message-ID: <3EDE74D1.767C6071@digeo.com>
Date: Wed, 04 Jun 2003 15:38:09 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Remove page_table_lock from vma manipulations
References: <133290000.1054765825@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> After more careful consideration, I don't see any reasons why
> page_table_lock is necessary for dealing with vmas.  I found one spot in
> swapoff, but it was easily changed to mmap_sem.

What keeps the VMA tree consistent when try_to_unmap_one()
runs find_vma()?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
