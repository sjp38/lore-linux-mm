Received: from f03n07e.au.ibm.com (f03n07s.au.ibm.com [9.185.166.74])
	by e3.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id KAA177968
	for <linux-mm@kvack.org>; Wed, 13 Jun 2001 10:57:25 -0400
From: Anil_K_Prasad/India/IBM@us.ibm.com
Received: from d73mta02.au.ibm.com (f06n02s [9.185.166.66])
	by f03n07e.au.ibm.com (8.11.1m3/NCO v4.96) with SMTP id f5DEwJw32250
	for <linux-mm@kvack.org>; Thu, 14 Jun 2001 00:58:19 +1000
Message-ID: <CA256A6A.00523D79.00@d73mta02.au.ibm.com>
Date: Wed, 13 Jun 2001 08:57:20 -0600
Subject: Re: kfree_skb!!
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <JGanapathy@storage.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>Hi, When I do any any operation on my driver, I get a warning as

>Warning: kfree_skb on hard IRQ c888bf85
you freeing up skb packet in interrupt handler.
try dev_kfree_skb_irq.

Regards,
Anil.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
