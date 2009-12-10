Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B0126600798
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 19:22:02 -0500 (EST)
Date: Wed, 9 Dec 2009 16:21:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [TRIVIAL] memcg: fix memory.memsw.usage_in_bytes for
 root cgroup
Message-Id: <20091209162109.567ff5fa.akpm@linux-foundation.org>
In-Reply-To: <20091210085929.56c63eb2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1260373738-17179-1-git-send-email-kirill@shutemov.name>
	<20091210085929.56c63eb2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, stable@kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 08:59:29 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed,  9 Dec 2009 17:48:58 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > We really want to take MEM_CGROUP_STAT_SWAPOUT into account.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: stable@kernel.org
> 
> Thanks.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Is this bug sufficiently serious to justify a -stable backport?

If so, why?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
