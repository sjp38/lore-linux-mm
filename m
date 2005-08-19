Date: Fri, 19 Aug 2005 05:03:54 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-ID: <20050819030354.GG22993@wotan.suse.de>
References: <20050818125236.4ffe1053.akpm@osdl.org> <p73y86ysz5c.fsf@verdi.suse.de> <20050819102706.62C7.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050819102706.62C7.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, peterc@gelato.unsw.edu.au, linux-mm@kvack.org, mbligh@mbligh.org, linux-ia64@vger.kernel.org, kravetz@us.ibm.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 19, 2005 at 11:29:32AM +0900, Yasunori Goto wrote:
> To hot-add a node, it is better that pgdat link list is removed.
> (Hot add code will set JUST node_online_map by it.)
> I posted a patch to remove this link list 3 month ago.
> http://marc.theaimsgroup.com/?l=linux-mm&m=111596924629564&w=2
> http://marc.theaimsgroup.com/?l=linux-mm&m=111596953711780&w=2

Agreed that's a better solution than my patch, and should
fix that bug too.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
