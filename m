Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 282546B004A
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 21:05:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L15Kcs022867
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 10:05:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D03745DE51
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:05:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0C6A1EF0A1
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:05:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B784E08007
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:05:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11D6EE08001
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:05:16 +0900 (JST)
Date: Tue, 21 Sep 2010 10:00:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFCv2][PATCH] add some drop_caches documentation and info
 messsge
Message-Id: <20100921100011.86f270de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
References: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010 09:50:47 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> 
> This version tones down the BUG_ON().  I also noticed that the
> documentation fails to mention that more than just the inode
> and dentry slabs are shrunk.
> 
> --
> 
> There is plenty of anecdotal evidence and a load of blog posts
> suggesting that using "drop_caches" periodically keeps your system
> running in "tip top shape".  Perhaps adding some kernel
> documentation will increase the amount of accurate data on its use.
> 
> If we are not shrinking caches effectively, then we have real bugs.
> Using drop_caches will simply mask the bugs and make them harder
> to find, but certainly does not fix them, nor is it an appropriate
> "workaround" to limit the size of the caches.
> 
> It's a great debugging tool, and is really handy for doing things
> like repeatable benchmark runs.  So, add a bit more documentation
> about it, and add a little KERN_NOTICE.  It should help developers
> who are chasing down reclaim-related bugs.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
