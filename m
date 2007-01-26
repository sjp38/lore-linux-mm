Date: Fri, 26 Jan 2007 12:05:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved
 regions
Message-Id: <20070126120554.671b1d6a.akpm@osdl.org>
In-Reply-To: <20070125214052.22841.33449.stgit@localhost.localdomain>
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, david@gibson.dropbear.id.au, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007 13:40:52 -0800
Adam Litke <agl@us.ibm.com> wrote:

> When expanding the stack, we don't currently check if the VMA will cross into
> an area of the address space that is reserved for hugetlb pages.  Subsequent
> faults on the expanded portion of such a VMA will confuse the low-level MMU
> code, resulting in an OOPS.  Check for this.

We prefer not to oops.  Is there any reason why this isn't a serious fix, needed
in 2.6.20 and 2.6.19?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
