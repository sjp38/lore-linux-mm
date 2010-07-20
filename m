Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B2A1A6B02A4
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 03:22:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6K7MA2s023515
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jul 2010 16:22:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F05A945DE6E
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:22:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC72B45DE70
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:22:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A3CF41DB803B
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:22:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36BEFE38002
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:22:09 +0900 (JST)
Date: Tue, 20 Jul 2010 16:17:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] v3 Update the node sysfs code
Message-Id: <20100720161726.7b223681.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C451EAF.1080505@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	<4C451EAF.1080505@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jul 2010 22:57:35 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the node sysfs code to be aware of the new capability for a memory
> block to contain multiple memory sections.  This requires an additional
> parameter to unregister_mem_sect_under_nodes so that we know which memory
> section of the memory block to unregister.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
