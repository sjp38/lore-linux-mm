Subject: Re: get_user_pages() still broken in 2.6
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040929000325.A6758@infradead.org>
References: <4159E85A.6080806@ammasso.com>
	 <20040929000325.A6758@infradead.org>
Content-Type: text/plain
Message-Id: <1096413678.16198.16.camel@localhost>
Mime-Version: 1.0
Date: Tue, 28 Sep 2004 16:21:18 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Timur Tabi <timur.tabi@ammasso.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-09-28 at 16:03, Christoph Hellwig wrote:
> get_user_pages locks the page in memory.  It doesn't do anything about ptes.

You probably want mlock(2) to keep the kernel from messing with the ptes
at all.  But, you should probably really be thinking about why you're
accessing the page tables at all.  I count *ONE* instance in drivers/
where page tables are accessed directly.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
