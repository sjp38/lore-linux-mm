Received: from willy by www.linux.org.uk with local (Exim 3.13 #1)
	id 14BeSV-0005GG-00
	for linux-mm@kvack.org; Thu, 28 Dec 2000 14:55:11 +0000
Date: Thu, 28 Dec 2000 14:55:11 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: __GFP_HIGH unused?
Message-ID: <20001228145511.B19693@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My trusty grep tells me that __GFP_HIGH is unused in the current 2.4.0-test12
tree.  Will it ever come back?  Or is GFP_ATOMIC being abused as a flag
somewhere?  If neither of these is true, am I right in saying there's no
difference between GFP_USER and GFP_KERNEL?

I was trying to amend the kernel-doc for kmalloc and started looking
through some of this, but I'm a little lost.  Things have changed a
lot since the description I was working from in Rubini's _Linux
Device Drivers_ (which covers 2.0).

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
