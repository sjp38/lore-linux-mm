Message-ID: <415ACACE.1020008@ammasso.com>
Date: Wed, 29 Sep 2004 09:46:38 -0500
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: Re: get_user_pages() still broken in 2.6
References: <4159E85A.6080806@ammasso.com>	 <20040929000325.A6758@infradead.org> <1096413678.16198.16.camel@localhost>
In-Reply-To: <1096413678.16198.16.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> You probably want mlock(2) to keep the kernel from messing with the ptes
> at all.

mlock() can only be called via sys_mlock(), which is a user-space call. 
  Not only that, but only root can call sys_mlock().  This is not 
compatible with our needs.

 >  But, you should probably really be thinking about why you're
> accessing the page tables at all.  I count *ONE* instance in drivers/
> where page tables are accessed directly.

I access PTEs to get the physical addresses of a user-space buffer, so 
that we can DMA to/from it directly.

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
