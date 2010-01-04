Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 551AE6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 17:30:26 -0500 (EST)
Date: Mon, 4 Jan 2010 14:28:19 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [BUGFIX][PATCH v2 -stable] memcg: avoid oom-killing
 innocent task in case of use_hierarchy
Message-ID: <20100104222818.GA20708@kroah.com>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
 <20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
 <20091125090050.e366dca5.kamezawa.hiroyu@jp.fujitsu.com>
 <20091125143218.96156a5f.nishimura@mxp.nes.nec.co.jp>
 <20091217094724.15ec3b27.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091217094724.15ec3b27.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: stable <stable@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 09:47:24AM +0900, Daisuke Nishimura wrote:
> Stable team.
> 
> Cay you pick this up for 2.6.32.y(and 2.6.31.y if it will be released) ?
> 
> This is a for-stable version of a bugfix patch that corresponds to the
> upstream commmit d31f56dbf8bafaacb0c617f9a6f137498d5c7aed.

I've applied it to the .32-stable tree, but it does not apply to .31.
Care to provide a version of the patch for that kernel if you want it
applied there?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
