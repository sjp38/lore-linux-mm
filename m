Message-ID: <20040619003712.35865.qmail@web10904.mail.yahoo.com>
Date: Fri, 18 Jun 2004 17:37:12 -0700 (PDT)
From: Ashwin Rao <ashwin_s_rao@yahoo.com>
Subject: Atomic operation for physically moving a page
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I want to copy a page from one physical location to
another (taking the appr. locks). To keep the
operation of copying and updation of all ptes and
caches atomic one way proposed by my team members was
to sleep the processes accessing the page.
ptep_to_mm gives us the mm_struct but container_of
cannot help to get to task_struct as it contains a
mm_struct pointer. Is there any way of identifying the
proccess's from the pte_entry.
Is there any way out to solve my original problem  of
keeping the whole operation of copying and updation
atomic as this is a bad solution for real time
processes but is there any other way out.

Ashwin



		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - Send 10MB messages!
http://promotions.yahoo.com/new_mail 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
