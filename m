Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AEC926B007E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:21:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955L6nZ023447
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:21:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA85C45DE4E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:21:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 98A6E45DE4D
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:21:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E4271DB803C
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:21:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDF21DB8038
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:21:03 +0900 (JST)
Date: Tue, 5 Oct 2010 14:15:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] v3 Update node sysfs code
Message-Id: <20101005141545.e3a78769.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CA629BA.60100@austin.ibm.com>
References: <4CA62700.7010809@austin.ibm.com>
	<4CA629BA.60100@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 13:34:34 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Update the node sysfs code to be aware of the new capability for a memory
> block to contain multiple memory sections and be aware of the memory block
> structure name changes (start_section_nr).  This requires an additional
> parameter to unregister_mem_sect_under_nodes so that we know which memory
> section of the memory block to unregister.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
