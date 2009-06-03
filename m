Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 85E2E5F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:21:48 -0400 (EDT)
Message-ID: <4A26072B.8040207@cn.fujitsu.com>
Date: Wed, 03 Jun 2009 13:16:27 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH mmotm 1/2] memcg: add interface to reset limits
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp> <20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Setting mem.limit or memsw.limit to 0 has no meaning
> in actual use(no process can run in such condition).
> 

I wrote a test program that set mem.limit to 0 to test
oom in memcg, and now it is in LTP, though I can modify
it accordingly.

> We don't have interface to reset mem.limit or memsw.limit now,
> so let's reset the mem.limit or memsw.limit to default(unlimited)
> when they are being set to 0.
> 

The idea of having a way to set the limit to unlimited is good,
but how about allow this by writing -1 to mem.limit?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
