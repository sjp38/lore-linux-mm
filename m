Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5985D6B016B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 17:49:28 -0400 (EDT)
Received: by yib2 with SMTP id 2so96047yib.14
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 14:49:23 -0700 (PDT)
Date: Wed, 31 Aug 2011 00:47:03 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: re: mm: frontswap: core code
Message-ID: <20110830214703.GB3705@shale.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org

Hello Dan Magenheimer,

This is a semi-automatic email to let you know that df0aade19b6a:
"mm: frontswap: core code" leads to the following Smatch complaint.

mm/frontswap.c +250 frontswap_curr_pages(7)
	 error: we previously assumed 'si' could be null (see line 252)

mm/frontswap.c
   249		spin_lock(&swap_lock);
   250		for (type = swap_list.head; type >= 0; type = si->next) {
                                                              ^^^^^^^^
Dereference.

   251			si = swap_info[type];
   252			if (si != NULL)
                            ^^^^^^^^^^
Check for NULL.

   253				totalpages += atomic_read(&si->frontswap_pages);
   254		}

These semi-automatic emails are in testing.  Let me know how they can
be improved.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
