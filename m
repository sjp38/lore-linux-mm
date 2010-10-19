Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7006D6B004A
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 20:50:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J0obgF029401
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Oct 2010 09:50:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B26A45DE61
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6503845DE55
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:50:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BE871DB803C
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:50:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2FBC1DB803A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:50:36 +0900 (JST)
Date: Tue, 19 Oct 2010 09:45:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 04/11] memcg: add lock to synchronize page accounting
 and migration
Message-Id: <20101019094512.11eabc62.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287448784-25684-5-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-5-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010 17:39:37 -0700
Greg Thelen <gthelen@google.com> wrote:

> Performance Impact: moving a 8G anon process.
> 
> Before:
> 	real    0m0.792s
> 	user    0m0.000s
> 	sys     0m0.780s
> 
> After:
> 	real    0m0.854s
> 	user    0m0.000s
> 	sys     0m0.842s
> 
> This score is bad but planned patches for optimization can reduce
> this impact.
> 

I'll post optimization patches after this set goes to -mm.
RFC version will be posted soon.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
