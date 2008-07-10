Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6AKUQRZ030097
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 16:30:26 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6AKZcBI038750
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 14:35:44 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6AKZcM9015399
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 14:35:38 -0600
Subject: Re: [PATCH -mm 1/5] swapcgroup (v3): add cgroup files
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080704151747.470d62a3.nishimura@mxp.nes.nec.co.jp>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	 <20080704151747.470d62a3.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain
Date: Thu, 10 Jul 2008 13:35:36 -0700
Message-Id: <1215722136.9398.59.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 15:17 +0900, Daisuke Nishimura wrote:
> +config CGROUP_SWAP_RES_CTLR
> +       bool "Swap Resource Controller for Control Groups"
> +       depends on CGROUP_MEM_RES_CTLR && SWAP
> +       help
> +         Provides a swap resource controller that manages and limits swap usage.
> +         Implemented as a add-on to Memory Resource Controller.

Could you make this just plain depend on 'CGROUP_MEM_RES_CTLR && SWAP'
and not make it configurable?  I don't think the resource usage really
justifies yet another .config knob to tune and break. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
