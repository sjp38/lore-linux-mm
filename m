Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBAAF6B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:47:08 -0400 (EDT)
Date: Wed, 3 Jun 2009 14:43:47 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm 1/2] memcg: add interface to reset limits
Message-Id: <20090603144347.81ec2ce1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4A26072B.8040207@cn.fujitsu.com>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
	<4A26072B.8040207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 03 Jun 2009 13:16:27 +0800, Li Zefan <lizf@cn.fujitsu.com> wrote:
> Daisuke Nishimura wrote:
> > Setting mem.limit or memsw.limit to 0 has no meaning
> > in actual use(no process can run in such condition).
> > 
> 
> I wrote a test program that set mem.limit to 0 to test
> oom in memcg, and now it is in LTP, though I can modify
> it accordingly.
> 
Thank you for your information, there is an acutual user then.

> > We don't have interface to reset mem.limit or memsw.limit now,
> > so let's reset the mem.limit or memsw.limit to default(unlimited)
> > when they are being set to 0.
> > 
> 
> The idea of having a way to set the limit to unlimited is good,
> but how about allow this by writing -1 to mem.limit?
> 
O.K.
I'll try it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
