Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id C31DA6B0265
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:22:50 -0500 (EST)
Received: by iofh3 with SMTP id h3so100510939iof.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:22:50 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id m9si6104360igx.48.2015.11.13.07.22.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 07:22:50 -0800 (PST)
Date: Fri, 13 Nov 2015 09:22:48 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
In-Reply-To: <201511131513.tADFDwJN030997@d06av03.portsmouth.uk.ibm.com>
Message-ID: <alpine.DEB.2.20.1511130919240.15385@east.gentwo.org>
References: <201511111413.65wysS6A%fengguang.wu@intel.com><20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org> <20151113125200.319a3101@mschwide> <201511131513.tADFDwJN030997@d06av03.portsmouth.uk.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Krebbel1 <Andreas.Krebbel@de.ibm.com>
Cc: mschwid2@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, heicars2@linux.vnet.ibm.com, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 13 Nov 2015, Andreas Krebbel1 wrote:

> this appears to be the result of aligning struct page to more than 8 bytes
> and putting it onto the stack - wich is only 8 bytes aligned.  The
> compiler has to perform runtime alignment to achieve that. It allocates
> memory using *alloca* and does the math with the returned pointer. Our
> dynamic stack allocation option basically only checks if there is an
> alloca user.

The slub uses of struct page only require an alignment of the page struct
on the stack to a word. So its fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
