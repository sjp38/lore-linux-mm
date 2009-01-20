Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ABFE36B0055
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:48:58 -0500 (EST)
Message-ID: <49752D5B.2090803@cn.fujitsu.com>
Date: Tue, 20 Jan 2009 09:48:11 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] memcg: NULL pointer dereference at rmdir on some
 NUMA systems v2
References: <49744499.2040101@cn.fujitsu.com>	<20090119185514.f3681783.kamezawa.hiroyu@jp.fujitsu.com> <20090120100806.b87b6ab0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090120100806.b87b6ab0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> fixed typos in description.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> N_POSSIBLE doesn't means there is memory...and force_empty can
> visit invalid node which have no pgdat.
> 
> To visit all valid nodes, N_HIGH_MEMORY should be used.
> 
> Changelog: v1->v2
>  - fix typo in description.
> 
> Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I've just tested this patch with a more complex test case.

Tested-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
