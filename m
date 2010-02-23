Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 916136B0082
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 01:26:20 -0500 (EST)
Date: Tue, 23 Feb 2010 15:21:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement
Message-Id: <20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 14:02:18 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Tue, 23 Feb 2010 12:03:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Nishimura-san, could you review and test your extreme test case with this ?
> > 
> Thank you for your patch.
> I don't know why, but the problem seems not so easy to cause in mmotm as in 2.6.32.8,
> but I'll try more anyway.
> 
I can triggered the problem in mmotm.

I'll continue my test with your patch applied.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
