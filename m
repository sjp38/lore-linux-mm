Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 691CF6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 23:09:14 -0400 (EDT)
Date: Sat, 2 May 2009 12:09:19 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090502120919.0c86b53a.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090502115649.027e4a88.d-nishimura@mtf.biglobe.ne.jp>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430094252.GG4430@balbir.in.ibm.com>
	<20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430181246.GM4430@balbir.in.ibm.com>
	<20090501133317.9c372d38.d-nishimura@mtf.biglobe.ne.jp>
	<20090501183256.GD4686@balbir.in.ibm.com>
	<20090502115649.027e4a88.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

> In my small box(i386/2CPU/2GB mem), a similar test shows after 12H
> about 600MB leak of swap cache before applying this patch,
Oops, not 600MB but 600KB.

Sorry,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
