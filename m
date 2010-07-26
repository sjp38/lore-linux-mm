Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0ABAA600227
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:28:19 -0400 (EDT)
Received: by gxk4 with SMTP id 4so1025768gxk.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 03:27:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100726120519.2EFA.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
	<20100726120519.2EFA.A69D9226@jp.fujitsu.com>
Date: Mon, 26 Jul 2010 15:57:58 +0530
Message-ID: <AANLkTimJ0NrT6M39UJvPd_X0YcEsCax6BCOQfqLdiopE@mail.gmail.com>
Subject: Re: [PATCH 4/4] memcg: add mm_vmscan_memcg_isolate tracepoint
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 8:36 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Memcg also need to trace page isolation information as global reclaim.
> This patch does it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
