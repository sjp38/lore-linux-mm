Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4GEqwPH005912
	for <linux-mm@kvack.org>; Tue, 16 May 2006 10:52:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4GEqnKh261058
	for <linux-mm@kvack.org>; Tue, 16 May 2006 08:52:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k4GEqndI006318
	for <linux-mm@kvack.org>; Tue, 16 May 2006 08:52:49 -0600
Subject: Re: [PATCH] Register sysfs file for hotpluged new node
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060516210608.A3E5.Y-GOTO@jp.fujitsu.com>
References: <20060516210608.A3E5.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 16 May 2006 07:51:31 -0700
Message-Id: <1147791091.6623.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-05-16 at 21:23 +0900, Yasunori Goto wrote:
> +       /*
> +        * register this node to sysfs.
> +        * this is depends on topology. So each arch has its own.
> +        */
> +       if (new_pgdat){
> +               ret = arch_register_node(nid);
> +               BUG_ON(ret);
> +       } 

Please don't do BUG_ON()s for things like this.  Memory hotplug _should_
handle failures from top to bottom and not screw you over.  It isn't a
crime or a bug to be out of memory.  

Have you run this past the ppc maintainers?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
