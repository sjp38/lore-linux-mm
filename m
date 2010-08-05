Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 883CD6B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 00:48:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o754p2Ar007685
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 13:51:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EE9145DE51
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:51:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6297C45DE53
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:51:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 447511DB8020
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:51:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD0581DB801B
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:51:01 +0900 (JST)
Date: Thu, 5 Aug 2010 13:45:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/9] v4  Move the find_memory_block() routine up
Message-Id: <20100805134546.fa8f2f96.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C581B67.1010202@austin.ibm.com>
References: <4C581A6D.9030908@austin.ibm.com>
	<4C581B67.1010202@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Aug 2010 08:36:39 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Move the find_memory_block() routine up to avoid needing a forward
> declaration in subsequent patches.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
