Received: from petasus.py.intel.com (petasus.py.intel.com [146.152.221.4])
	by hermes.py.intel.com (8.12.9-20030918-01/8.12.9/d: large-outer.mc,v 1.9 2004/01/09 00:55:23 root Exp $) with ESMTP id i626ZKS3024133
	for <linux-mm@kvack.org>; Fri, 2 Jul 2004 06:35:20 GMT
Received: from orsmsxvs040.jf.intel.com (orsmsxvs040.jf.intel.com [192.168.65.206])
	by petasus.py.intel.com (8.12.9-20030918-01/8.12.9/d: large-inner.mc,v 1.10 2004/03/01 19:22:27 root Exp $) with SMTP id i626aXwM025585
	for <linux-mm@kvack.org>; Fri, 2 Jul 2004 06:36:33 GMT
Received: from orsmsx332.amr.corp.intel.com ([192.168.65.60])
 by orsmsxvs040.jf.intel.com (SAVSMTP 3.1.2.35) with SMTP id M2004070123351700866
 for <linux-mm@kvack.org>; Thu, 01 Jul 2004 23:35:17 -0700
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: Which is the proper way to bring in the backing store behind an inode as an struct page?
Date: Thu, 1 Jul 2004 23:34:56 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25A6EBED8@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all

Dummy question that has been evading me for the last hours. Can you
help? Please bear with me here, I am a little lost in how to deal
with inodes and the cache.

I have a problem where I have to modify a value in user space from 
inside a function called from do_exit() [this is for robust mutexes].
The reason for this is when a task exits holding a mutex, it needs to
update the user space word that represents the mutex to indicate that
it is dead. This is needed to allow for fast-lock operations when 
there is no mutex contention.

I need to be able to kmap the location where the page is so I can
modify it. The problem is that in one of the cases, when the thing 
is in a shared mapping (linear or non-linear), I just have the inode,
the page offset and the offset into the page.

Thus, what I need is a way that given the pair (inode,pgoff) 
returns to me the 'struct page *' if the thing is cached in memory or
pulls it up from swap/file into memory and gets me a 'struct page *'.

Is there a way to do this?

Thanks

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own (and my fault)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
