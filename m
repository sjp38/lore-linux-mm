Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 71AA16B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 00:52:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o754tSbt002202
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 13:55:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1785645DE7E
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:55:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE7FE45DE7D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:55:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62A58E08002
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:55:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6096E38005
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:55:23 +0900 (JST)
Date: Thu, 5 Aug 2010 13:50:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] v4  Add section count to memory_block
Message-Id: <20100805135031.bbcfd741.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C581BDD.1040601@austin.ibm.com>
References: <4C581A6D.9030908@austin.ibm.com>
	<4C581BDD.1040601@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Aug 2010 08:38:37 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Add a section count property to the memory_block struct to track the number
> of memory sections that have been added/removed from a memory block. This
> allows us to know when the last memory section of a memory block has been
> removed so we can remove the memory block.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
