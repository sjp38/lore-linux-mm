Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E18F06B007B
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:46:44 -0500 (EST)
Date: Wed, 25 Nov 2009 12:45:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH v2 -stable] memcg: avoid oom-killing innocent
 task in case of use_hierarchy
Message-Id: <20091125124551.9d45e0e4.akpm@linux-foundation.org>
In-Reply-To: <20091125143218.96156a5f.nishimura@mxp.nes.nec.co.jp>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
	<20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
	<20091125090050.e366dca5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091125143218.96156a5f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable <stable@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 2009 14:32:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Hmm. Maybe not-expected behavior...could you add comment ?
> > 
> How about this ?
> 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > (*) I'm sorry I can't work enough in these days.
> > 
> 
> BTW, this patch conflict with oom-dump-stack-and-vm-state-when-oom-killer-panics.patch
> in current mmotm(that's why I post mmotm version separately), so this bug will not be fixed
> till 2.6.33 in linus-tree.
> So I think this patch should go in 2.6.32.y too.

I don't actually have a 2.6.33 version of this patch yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
