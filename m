Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k2A85wvg016243 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:05:58 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k2A85u0Y031406 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:05:56 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (s4 [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D721E1CC00F
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:05:54 +0900 (JST)
Received: from ml9.s.css.fujitsu.com (ml9.s.css.fujitsu.com [10.23.4.199])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FAE21CC0BC
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 17:05:54 +0900 (JST)
Date: Fri, 10 Mar 2006 17:05:53 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get node id at probe memory)
In-Reply-To: <20060309040031.2be49ec2.akpm@osdl.org>
References: <20060308212646.0028.Y-GOTO@jp.fujitsu.com> <20060309040031.2be49ec2.akpm@osdl.org>
Message-Id: <20060310154600.CA73.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> >
> > When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
> >  before calling add_memory_node(nid, start, size).
> > 
> >  Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
> >  define arch_nid_probe(paddr);
> > 
> >  Powerpc has nice function. X86_64 has not.....
> 
> This patch uses an odd mixture of __devinit and <nothing-at-all> in
> arch/x86_64/mm/init.c.  I guess it should be using __meminit
> throughout.

  Oh... I made mistake. I'll fix them.



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
