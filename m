Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2KGeU22012757
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 11:40:30 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2KGeK7U235376
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 11:40:20 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2KGeJTM012149
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 11:40:20 -0500
Subject: Re: [PATCH: 017/017]Memory hotplug for new nodes
	v.4.(arch_register_node() for ia64)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060320183634.7E9C.Y-GOTO@jp.fujitsu.com>
References: <20060317163911.C659.Y-GOTO@jp.fujitsu.com>
	 <1142618434.10906.99.camel@localhost.localdomain>
	 <20060320183634.7E9C.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 08:39:04 -0800
Message-Id: <1142872744.10906.125.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-20 at 18:57 +0900, Yasunori Goto wrote:
> Current i386's code treats "parent node" in arch_register_node(). 
> But, IA64 doesn't need it.

I'm not sure I understand.  What do you mean by "treats"?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
