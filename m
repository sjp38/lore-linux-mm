Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5D1FA6B005D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 18:33:58 -0400 (EDT)
Received: from mail (unknown [137.82.2.7])
	by sparc.brc.ubc.ca (Postfix) with ESMTP id 0A5A7526C1DE
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 15:40:31 -0700 (PDT)
Date: Mon, 20 Jul 2009 15:53:32 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Replacing 0x% with %# ?
Message-ID: <alpine.DEB.1.00.0907201543230.22052@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi MM list:

I am newbie and wish to contribute tiny bit. Before I submit a 
trivial patch, I would ask if it is worth replacing  '0x%' with '%#' in printk in mm/*.c? 
If it is going to be noise for you guys, I would drop it and keep silent 
:).  

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
