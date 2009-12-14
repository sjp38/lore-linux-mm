Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A27086B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:53:35 -0500 (EST)
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
	<20091208211639.8499FB151F@basil.firstfloor.org>
	<6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
	<20091210014212.GI18989@one.firstfloor.org>
	<20091210022113.GJ3722@balbir.in.ibm.com>
	<20091211021405.GA10693@localhost>
Date: Mon, 14 Dec 2009 13:53:30 +0100
In-Reply-To: <20091211021405.GA10693@localhost> (Wu Fengguang's message of "Fri, 11 Dec 2009 10:14:05 +0800")
Message-ID: <87tyvtyawl.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Haicheng" <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> writes:
>
> We could keep an fd open on the desired cgroup, in user space: 
>
>         #!/bin/bash
>
>         mkdir /cgroup/hwpoison && \
>         exec 9<>/cgroup/hwpoison/tasks || exit 1
>
> A bit simpler than an in-kernel fget_light() or CSS refcount :)

FYI, I decided to not do any of this in .33, but just keep the 
ugly-but-working inode hack. We can look at fixing that for .34.
These interfaces are debugfs, so can be changed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
