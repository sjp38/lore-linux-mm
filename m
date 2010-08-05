Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FC226B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 00:55:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o754w8dG003388
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 13:58:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5575745DE7D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:58:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 152BB45DE79
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:58:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C45D91DB803A
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:58:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DB2E1DB803F
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:58:07 +0900 (JST)
Date: Thu, 5 Aug 2010 13:53:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] v4  Add mutex for add/remove of memory blocks
Message-Id: <20100805135314.7229d07c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C581C26.5080007@austin.ibm.com>
References: <4C581A6D.9030908@austin.ibm.com>
	<4C581C26.5080007@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Aug 2010 08:39:50 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Add a new mutex for use in adding and removing of memory blocks.  This
> is needed to avoid any race conditions in which the same memory block could
> be added and removed at the same time.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But a nitpick (see below)

> ---
>  drivers/base/memory.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> Index: linux-2.6/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.orig/drivers/base/memory.c	2010-08-02 13:35:00.000000000 -0500
> +++ linux-2.6/drivers/base/memory.c	2010-08-02 13:45:34.000000000 -0500
> @@ -27,6 +27,8 @@
>  #include <asm/atomic.h>
>  #include <asm/uaccess.h>
>  
> +static struct mutex mem_sysfs_mutex;
> +

For static symbol of mutex, we usually do
	static DEFINE_MUTEX(mem_sysfs_mutex);

Then, extra calls of mutex_init() is not required.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
