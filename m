Received: from talaria.jf.intel.com (talaria.jf.intel.com [10.7.209.7])
	by caduceus.jf.intel.com (8.12.9-20030918-01/8.12.9/d: major-outer.mc,v 1.15 2004/01/30 18:16:28 root Exp $) with ESMTP id i630aMT3026661
	for <linux-mm@kvack.org>; Sat, 3 Jul 2004 00:36:22 GMT
Received: from orsmsxvs041.jf.intel.com (orsmsxvs041.jf.intel.com [192.168.65.54])
	by talaria.jf.intel.com (8.12.9-20030918-01/8.12.9/d: major-inner.mc,v 1.10 2004/03/01 19:21:36 root Exp $) with SMTP id i630Vewt001026
	for <linux-mm@kvack.org>; Sat, 3 Jul 2004 00:31:53 GMT
Received: from orsmsx332.amr.corp.intel.com ([192.168.65.60])
 by orsmsxvs041.jf.intel.com (SAVSMTP 3.1.2.35) with SMTP id M2004070217371618804
 for <linux-mm@kvack.org>; Fri, 02 Jul 2004 17:37:16 -0700
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: Which is the proper way to bring in the backing store behind an inode as an struct page?
Date: Fri, 2 Jul 2004 17:37:10 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25A6EBEEE@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ken

> From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com]
> 
> Perez-Gonzalez, Inaky wrote on Thursday, July 01, 2004 11:35 PM
> > Dummy question that has been evading me for the last hours. Can you
> > help? Please bear with me here, I am a little lost in how to deal
> > with inodes and the cache.
> >
> > ....
> >
> > Thus, what I need is a way that given the pair (inode,pgoff)
> > returns to me the 'struct page *' if the thing is cached in memory or
> > pulls it up from swap/file into memory and gets me a 'struct page *'.
> >
> > Is there a way to do this?
> 
> find_get_page() might be the one you are looking for.

Something like this? [I am trying blindly]

page = find_get_page (inode->i_mapping, pgoff)

Under which circumstances will this fail? [I am guessing the only ones
are if the page offset is out of the limits of the map]. What about 
i_mapping? When is it not defined? [ie: NULL].

Thanks

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own (and my fault)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
