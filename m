Message-ID: <3D654C8F.30400@us.ibm.com>
Date: Thu, 22 Aug 2002 13:41:51 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [Lse-tech] [patch] SImple Topology API v0.3 (1/2)
References: <3D6537D3.3080905@us.ibm.com> <20020822202239.A30036@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

The file asm/mmzone.h needs to be included in both the CONFIG_DISCONTIGMEM and 
!CONFIG_DISCONTIGMEM cases (at least after my patch).  This just pulls the 
#include out of the #ifdefs.

Cheers!

-Matt

Christoph Hellwig wrote:
> On Thu, Aug 22, 2002 at 12:13:23PM -0700, Matthew Dobson wrote:
> 
>>--- linux-2.5.27-vanilla/include/linux/mmzone.h	Sat Jul 20 12:11:05 2002
>>+++ linux-2.5.27-api/include/linux/mmzone.h	Wed Jul 24 17:33:41 2002
>>@@ -220,15 +20,15 @@
>> #define NODE_MEM_MAP(nid)	mem_map
>> #define MAX_NR_NODES		1
>> 
>>-#else /* !CONFIG_DISCONTIGMEM */
>>-
>>-#include <asm/mmzone.h>
>>+#else /* CONFIG_DISCONTIGMEM */
>> 
>> /* page->zone is currently 8 bits ... */
>> #define MAX_NR_NODES		(255 / MAX_NR_ZONES)
>> 
>> #endif /* !CONFIG_DISCONTIGMEM */
>> 
>>+#include <asm/mmzone.h>
>>+
> 
> 
> What is the exact purpose of this change?
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> Lse-tech mailing list
> Lse-tech@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lse-tech
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
