Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 209106B007B
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:13:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955DtFc020110
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:13:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E413A45DE55
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:13:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C0FE445DE53
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:13:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A56731DB805A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:13:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 52E671DB8038
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:13:54 +0900 (JST)
Date: Tue, 5 Oct 2010 14:08:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] v3 Add section count to memory_block struct
Message-Id: <20101005140835.9c80c2e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CA628D0.6030508@austin.ibm.com>
References: <4CA62700.7010809@austin.ibm.com>
	<4CA628D0.6030508@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 13:30:40 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Add a section count property to the memory_block struct to track the number
> of memory sections that have been added/removed from a memory block. This
> allows us to know when the last memory section of a memory block has been
> removed so we can remove the memory block.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

a nitpick,


> Index: linux-next/include/linux/memory.h
> ===================================================================
> --- linux-next.orig/include/linux/memory.h	2010-09-29 14:56:29.000000000 -0500
> +++ linux-next/include/linux/memory.h	2010-09-30 14:13:50.000000000 -0500
> @@ -23,6 +23,8 @@
>  struct memory_block {
>  	unsigned long phys_index;
>  	unsigned long state;
> +	int section_count;

I prefer
	int section_count; /* updated under mutex */

or some for this kind of non-atomic counters. but nitpick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
