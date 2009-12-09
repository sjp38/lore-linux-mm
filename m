Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3587E60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 04:15:14 -0500 (EST)
Date: Wed, 9 Dec 2009 10:15:10 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-ID: <20091209091510.GE18989@one.firstfloor.org>
References: <200912081016.198135742@firstfloor.org> <20091208211639.8499FB151F@basil.firstfloor.org> <4B1F2FC6.7040406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B1F2FC6.7040406@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I have a question, can try_get_mem_cgroup_from_page() return
> root_mem_cgroup?

It could be called for any page.


> if it can, then css->cgroup->dentry is NULL, if memcg is
> not mounted and there is no subdir in memcg. Because the root
> cgroup of an inactive subsystem has no dentry.

Thanks. I'll just add an return -EINVAL for this case, sounds good?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
