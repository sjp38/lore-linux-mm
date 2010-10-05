Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 08B856B004A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 01:11:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o955BWWF015236
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 14:11:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 613E745DE6E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:11:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2709945DE4D
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:11:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C853D1DB8037
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:11:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 617521DB803F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:11:28 +0900 (JST)
Date: Tue, 5 Oct 2010 14:06:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] v3 Add mutex for adding/removing memory blocks
Message-Id: <20101005140604.6bbd8ae0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CA62896.2060307@austin.ibm.com>
References: <4CA62700.7010809@austin.ibm.com>
	<4CA62896.2060307@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 13:29:42 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Add a new mutex for use in adding and removing of memory blocks.  This
> is needed to avoid any race conditions in which the same memory block could
> be added and removed at the same time.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
Reviewed-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
