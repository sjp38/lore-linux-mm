Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2HHuswa013735
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:56:54 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2HHuiR5093220
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:56:44 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2HHuhmA011239
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:56:43 -0500
Subject: Re: [PATCH: 011/017]Memory hotplug for new nodes v.4.(start kswapd)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060317163538.C64D.Y-GOTO@jp.fujitsu.com>
References: <20060317163538.C64D.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 17 Mar 2006 09:55:47 -0800
Message-Id: <1142618147.10906.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-17 at 17:22 +0900, Yasunori Goto wrote
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +/* start new kswapd for new node */
> +extern int kswapd_run(int nid);
> +#endif

I'd move this code down to where you actually use the extern.  I'd also
take the #ifdef out.  It won't hurt anything to have the extern there
all the time.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
