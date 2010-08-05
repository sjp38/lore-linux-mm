Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D6996B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 01:01:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7554d4U006553
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 14:04:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A949E45DE79
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 14:04:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8901345DE60
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 14:04:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A5D41DB803F
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 14:04:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 244C61DB8037
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 14:04:39 +0900 (JST)
Date: Thu, 5 Aug 2010 13:59:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] v4 Update the find_memory_block declaration
Message-Id: <20100805135944.97ecbaa4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C581C99.8090201@austin.ibm.com>
References: <4C581A6D.9030908@austin.ibm.com>
	<4C581C99.8090201@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Aug 2010 08:41:45 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the find_memory_block declaration to to take a struct mem_section *
> so that it matches the definition.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm...my mmotm-0727 has this definition in memory.h...

extern struct memory_block *find_memory_block(struct mem_section *);

What patch makes it unsigned long ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
