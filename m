Received: from f03n07e.au.ibm.com
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id SAA123974
	for <linux-mm@kvack.org>; Thu, 4 May 2000 18:33:08 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e.au.ibm.com (8.8.8m2/8.8.7) with SMTP id SAA58546
	for <linux-mm@kvack.org>; Thu, 4 May 2000 18:37:51 +1000
Message-ID: <CA2568D5.002F65EE.00@d73mta05.au.ibm.com>
Date: Thu, 4 May 2000 13:58:53 +0530
Subject: PG_dirty bit
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kerenl 2.2.5-15

In try_to_swap_out () after the page is found to be dirty it is swapped
out.
One of the comments there says that it should just set the dirty bit in
page_map and drop pte .
But in the code I could not find anywhere PG_dirty flag being set in
page_map.
Or there is some magic involved ?

If I have missed out something please enlighten me.

Nilesh Patel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
