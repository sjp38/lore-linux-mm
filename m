Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8PIhdBI007481
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 14:43:39 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8PIeotm215206
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 14:40:50 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8PIen6k021211
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 14:40:49 -0400
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 11:40:47 -0700
Message-Id: <1222368047.15523.81.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-25 at 15:32 +0900, KAMEZAWA Hiroyuki wrote:
> @@ -949,6 +953,11 @@ struct mem_section {
> 
>         /* See declaration of similar field in struct zone */
>         unsigned long *pageblock_flags;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +       /* see page_cgroup.h */
> +       struct page_cgroup *page_cgroup;
> +       unsigned long pad;
> +#endif
>  };

I thought the use of this variable was under the

	+#ifdef CONFIG_FLAT_NODE_MEM_MAP

options.  Otherwise, we unconditionally bloat mem_section, right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
