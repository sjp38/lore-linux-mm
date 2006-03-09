Date: Thu, 9 Mar 2006 04:00:31 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get
 node id at probe memory)
Message-Id: <20060309040031.2be49ec2.akpm@osdl.org>
In-Reply-To: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
References: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
>  before calling add_memory_node(nid, start, size).
> 
>  Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
>  define arch_nid_probe(paddr);
> 
>  Powerpc has nice function. X86_64 has not.....

This patch uses an odd mixture of __devinit and <nothing-at-all> in
arch/x86_64/mm/init.c.  I guess it should be using __meminit
throughout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
