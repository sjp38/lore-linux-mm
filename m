Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2HHDGgm027552
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:13:16 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2HHGC39186762
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 10:16:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2HHDEtW004057
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 10:13:14 -0700
Subject: Re: [PATCH: 002/017]Memory hotplug for new nodes v.4.(change name
	old add_memory() to arch_add_memory())
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
References: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 17 Mar 2006 09:12:18 -0800
Message-Id: <1142615538.10906.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-17 at 17:20 +0900, Yasunori Goto wrote:
> This patch changes name of old add_memory() to arch_add_memory.
> and use node id to get pgdat for the node at NODE_DATA().
> 
> Note: Powerpc's old add_memory() is defined as __devinit. However,
>       add_memory() is usually called only after bootup. 
>       I suppose it may be redundant. But, I'm not sure about powerpc.
>       So, I keep it. (But, __meminit is better than __devinit at least.)

My thoughts when originally designing the API were that the architecture
may be the only bit that actually knows where the memory _is_.  So, we
shouldn't involve the generic code in figuring this out.

You can see the result of this in the next patch because there is a new
function introduced to hide the arch-specific node lookup.  If that was
simply done in the already arch-specific add_memory() function, then you
wouldn't need arch_nid_probe() and its related #ifdefs at all.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
