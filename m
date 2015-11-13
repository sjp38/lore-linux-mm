Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 72C476B0269
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 12:05:36 -0500 (EST)
Received: by ioc74 with SMTP id 74so103413924ioc.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 09:05:36 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id a187si26418674ioe.184.2015.11.13.09.05.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 09:05:35 -0800 (PST)
Date: Fri, 13 Nov 2015 11:05:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
In-Reply-To: <201511131532.tADFWgYs000305@d06av09.portsmouth.uk.ibm.com>
Message-ID: <alpine.DEB.2.20.1511131105030.16068@east.gentwo.org>
References: <201511111413.65wysS6A%fengguang.wu@intel.com><20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org> <20151113125200.319a3101@mschwide> <201511131513.tADFDwJN030997@d06av03.portsmouth.uk.ibm.com> <alpine.DEB.2.20.1511130919240.15385@east.gentwo.org>
 <201511131532.tADFWgYs000305@d06av09.portsmouth.uk.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Krebbel1 <Andreas.Krebbel@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, heicars2@linux.vnet.ibm.com, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com


On Fri, 13 Nov 2015, Andreas Krebbel1 wrote:

> > The slub uses of struct page only require an alignment of the page
> struct
> > on the stack to a word. So its fine.
>
> Our compare and swap double hardware instruction unfortunately requires 16
> byte alignment. That's probably the reason why this alignment has been
> picked. So I don't think that we can easily get rid of it.

The cmpxchg double is not run on the page struct on the stack. Its just
used because I wanted to duplicate the counter layout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
