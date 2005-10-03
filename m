Date: Mon, 03 Oct 2005 14:19:53 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
In-Reply-To: <1128096445.6145.36.camel@localhost>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com> <1128096445.6145.36.camel@localhost>
Message-Id: <20051003135936.0EAE.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> This works around my compile problem for now.  But, it might cause some
> more issues.  Can you take a closer look?

It works well in my ia64 box.
But, I have not understood why this patch moves also the lines from
is_highmem_idx() to lowmem_reserve_ratio_sysctl_handler() yet.
Is it necessary?
If no, the patch becomes a bit smaller. :-)

Thanks.

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
