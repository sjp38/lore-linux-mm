Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 475916B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 03:21:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6K7LBd2026710
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jul 2010 16:21:12 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B745645DE4D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:21:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DC7845DE60
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:21:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CC73E38002
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:21:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2717EE38001
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:21:11 +0900 (JST)
Date: Tue, 20 Jul 2010 16:16:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] v3 Update the find_memory_block declaration
Message-Id: <20100720161629.1551837f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C451E60.8080702@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	<4C451E60.8080702@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jul 2010 22:56:16 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the find_memory_block declaration to to take a struct mem_section *
> so that it matches the definition.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
