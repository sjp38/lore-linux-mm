Date: Wed, 02 Oct 2002 11:57:26 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH] Snapshot of shared page tables
Message-ID: <83240000.1033577846@baldur.austin.ibm.com>
In-Reply-To: <E17wmit-0001bH-00@starship>
References: <45850000.1033570655@baldur.austin.ibm.com>
 <E17wmit-0001bH-00@starship>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, October 02, 2002 18:51:41 +0200 Daniel Phillips
<phillips@arcor.de> wrote:

> Interesting, you substituted pte_page_lock(ptepage) for
> mm->page_table_lock. Could you wax poetic about that, please?

Sure.  If a pte page is shared, the mm->page_table_lock is not sufficient
to protect the rest of the page fault.  Therefore we need a lock at the pte
page level.  The mm->page_table_lock is held during the page fault until we
have a valid and locked pte page we're working on, then it's dropped for
the rest of the fault.

Feel free to poke holes in my logic, but I think it's the right locking
model for shared pte pages.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
