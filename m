Subject: Re: Atomic operation for physically moving a page (for memory
	defragmentation)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040623.205906.71913783.taka@valinux.co.jp>
References: <20040619031536.61508.qmail@web10902.mail.yahoo.com>
	 <1087619137.4921.93.camel@nighthawk>
	 <20040623.205906.71913783.taka@valinux.co.jp>
Content-Type: text/plain
Message-Id: <1088024190.28102.24.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 23 Jun 2004 13:56:30 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: ashwin_s_rao@yahoo.com, Valdis.Kletnieks@vt.edu, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-06-23 at 04:59, Hirokazu Takahashi wrote:
> We should know that many part of kernel code will access the page
> without holding a lock_page(). The lock_page() can't block them.

No, but it will block them from establishing a new PTE to the page.  You
need to:

1. make sure no new PTEs can be established to the page
2. make sure there are no valid PTEs to the page.
3. do the move

My suggestion relates to 1, only.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
