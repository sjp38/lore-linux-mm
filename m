Date: Wed, 13 Jul 2005 14:09:19 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
In-Reply-To: <9320000.1121179193@[10.10.2.4]>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com> <9320000.1121179193@[10.10.2.4]>
Message-Id: <20050713110109.F796.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > To avoid this panic, following patch skips no DMA'ble node when 
> > lower address is required.
> > I tested this patch on my Tiger 4 and our new server.
> 
> Seems reasonable ... but do you not want to check that the returned
> ptr is actually less than MAX_DMA_ADDRESS as well? 

Well... If there isn't enough DMA area in a node by too much
lower memory request or by something strange memory map in the node,
its case might occur.
I don't know it will really happen. But, the after check might be better
than nothing.

To tell the truth, I did the after check at first
"instead of" previous check like this patch. 
In its patch, if its DMA check failed, 
allocated area are should be freed by free_bootmem_core(). 
But hung up occurred by it, and I changed my patch to previous check
instead of deep investigation of its hung up.

Ok. I'll investigate more.

Thanks.
-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
