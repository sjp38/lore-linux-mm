Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0CA5D6B007E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:18:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955IkuC022332
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:18:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EF5745DE4F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:18:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C4D45DE3E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:18:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 285DE1DB804D
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:18:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D29C31DB804E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:18:45 +0900 (JST)
Date: Tue, 5 Oct 2010 14:13:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] v3 Allow memory blocks to span multiple memory
 sections
Message-Id: <20101005141325.81c61dec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CA62FE2.2000003@austin.ibm.com>
References: <4CA62700.7010809@austin.ibm.com>
	<4CA62917.80008@austin.ibm.com>
	<4CA62FE2.2000003@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 14:00:50 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the memory sysfs code such that each sysfs memory directory is now
> considered a memory block that can span multiple memory sections per
> memory block.  The default size of each memory block is SECTION_SIZE_BITS
> to maintain the current behavior of having a single memory section per
> memory block (i.e. one sysfs directory per memory section).
> 
> For architectures that want to have memory blocks span multiple
> memory sections they need only define their own memory_block_size_bytes()
> routine.
> 
This should be commented in code before MEMORY_BLOCK_SIZE declaration.

> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
