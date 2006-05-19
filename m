Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4JH3AOi013433
	for <linux-mm@kvack.org>; Fri, 19 May 2006 13:03:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4JH3AOK207474
	for <linux-mm@kvack.org>; Fri, 19 May 2006 13:03:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4JH3ADj012890
	for <linux-mm@kvack.org>; Fri, 19 May 2006 13:03:10 -0400
Subject: Re: [PATCH] Register sysfs file for hotpluged new node take 2.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060518143742.E2FB.Y-GOTO@jp.fujitsu.com>
References: <20060518143742.E2FB.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 19 May 2006 10:01:47 -0700
Message-Id: <1148058107.6623.160.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-18 at 14:50 +0900, Yasunori Goto wrote:
> +       if (new_pgdat) {
> +               ret = register_one_node(nid);
> +               /*
> +                * If sysfs file of new node can't create, cpu on the node
> +                * can't be hot-added. There is no rollback way now.
> +                * So, check by BUG_ON() to catch it reluctantly..
> +                */
> +               BUG_ON(ret);
> +       } 

How about we register the node in sysfs _before_ it is
set_node_online()'d?  Effectively an empty node with no memory and no
CPUs.  It might be a wee bit confusing to any user tools watching the
NUMA sysfs stuff, but I think it beats a BUG().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
