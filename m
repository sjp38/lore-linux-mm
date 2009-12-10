Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3990160021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 20:42:29 -0500 (EST)
Date: Thu, 10 Dec 2009 02:42:12 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-ID: <20091210014212.GI18989@one.firstfloor.org>
References: <200912081016.198135742@firstfloor.org> <20091208211639.8499FB151F@basil.firstfloor.org> <6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> While the functionality sounds useful, the interface (passing an inode
> number) feels a bit ugly to me. Also, if that group is deleted and a
> new cgroup created, you could end up reusing the inode number.

Please note this is just a testing interface, doesn't need to be
100% fool-proof. It'll never be used in production.

> 
> How about an approach where you write either the cgroup path (relative
> to the memcg mount) or an fd open on the desired cgroup? Then you
> could store a (counted) css reference rather than an inode number,
> which would make the filter function cleaner too, since it would just
> need to compare css objects.

Sounds complicated, I assume it would be much more code?
I would prefer to keep the testing interfaces as simple as possible.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
