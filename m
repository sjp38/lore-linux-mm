Received: from talaria.sc.intel.com (talaria.sc.intel.com [10.3.253.5])
	by hermes.sc.intel.com (8.12.9-20030918-01/8.12.9/d: major-outer.mc,v 1.15 2004/01/30 18:16:28 root Exp $) with ESMTP id i62I8gIZ009340
	for <linux-mm@kvack.org>; Fri, 2 Jul 2004 18:08:42 GMT
Message-Id: <200407021805.i62I5TY14608@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Which is the proper way to bring in the backing store behind an inode as an struct page?
Date: Fri, 2 Jul 2004 11:07:29 -0700
In-Reply-To: <F989B1573A3A644BAB3920FBECA4D25A6EBED8@orsmsx407>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Perez-Gonzalez, Inaky wrote on Thursday, July 01, 2004 11:35 PM
> Dummy question that has been evading me for the last hours. Can you
> help? Please bear with me here, I am a little lost in how to deal
> with inodes and the cache.
>
> ....
>
> Thus, what I need is a way that given the pair (inode,pgoff)
> returns to me the 'struct page *' if the thing is cached in memory or
> pulls it up from swap/file into memory and gets me a 'struct page *'.
>
> Is there a way to do this?

find_get_page() might be the one you are looking for.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
