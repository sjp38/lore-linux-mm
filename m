Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBGMk46q020938
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:46:04 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBGMk4qZ256946
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:46:04 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBGMk4qY009315
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:46:04 -0500
Subject: Re: [patch] [RFC] move 'struct page' into its own header
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041216222513.GA15451@infradead.org>
References: <E1Cf3jM-00034h-00@kernel.beaverton.ibm.com>
	 <20041216222513.GA15451@infradead.org>
Content-Type: text/plain
Message-Id: <1103237161.13614.2388.camel@localhost>
Mime-Version: 1.0
Date: Thu, 16 Dec 2004 14:46:01 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-12-16 at 14:25, Christoph Hellwig wrote:
> On Thu, Dec 16, 2004 at 02:04:15PM -0800, Dave Hansen wrote:
> > So, put 'struct page' into structpage.h, along with a nasty comment
> > telling everyone to keep their grubby mitts out of the file.

> What about calling it page.h?  structfoo.h sounds like a really strange
> name.

The only reason I didn't do that is that there is already an
asm/page.h.  But, linux/page.h would be a fine name, too.

> And while you're at it page-flags.h should probably be merged into
> it.

The only tricky part might be page-flags.h includes asm/pgtable.h, which
(on i386) includes linux/slab.h, which includes asm/page.h.  This might
somewhat restrict the number of places that the new header can be
included.  As it stands, it can be included (and get you a full
definition of struct page) almost anywhere.

But, I'm not quite sure why page-flags.h even needs asm/pgtable.h.  I
just took it out in i386, and it still compiles just fine.  Maybe it is
needed for another architecture.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
