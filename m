Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4DEE96B0082
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:19:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955JlQ7022811
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:19:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A00845DE62
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:19:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE1BF45DE66
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:19:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C58F91DB803B
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:19:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F1FD1DB8041
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:19:46 +0900 (JST)
Date: Tue, 5 Oct 2010 14:14:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] v3 rename phys_index properties of memory block
 struct
Message-Id: <20101005141427.e5fafa25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CA62982.5080900@austin.ibm.com>
References: <4CA62700.7010809@austin.ibm.com>
	<4CA62982.5080900@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 13:33:38 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the 'phys_index' property of a the memory_block struct to be
> called start_section_nr, and add a end_section_nr property.  The
> data tracked here is the same but the updated naming is more in line
> with what is stored here, namely the first and last section number
> that the memory block spans.
> 
> The names presented to userspace remain the same, phys_index for
> start_section_nr and end_phys_index for end_section_nr, to avoid breaking
> anything in userspace.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
