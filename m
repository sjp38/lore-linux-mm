Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DF13D600227
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:27:00 -0400 (EDT)
Received: by iwn2 with SMTP id 2so3240015iwn.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 03:26:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100726120422.2EF7.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
	<20100726120422.2EF7.A69D9226@jp.fujitsu.com>
Date: Mon, 26 Jul 2010 15:56:58 +0530
Message-ID: <AANLkTikxoRcPErYdc05HyMctmizS_e9gt=esMuZKhfuC@mail.gmail.com>
Subject: Re: [PATCH 3/4] vmscan: convert mm_vmscan_lru_isolate to DEFINE_EVENT
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 8:35 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Mel Gorman recently added some vmscan tracepoints. Unfortunately
> they are covered only global reclaim. But we want to trace memcg
> reclaim too.
>
> Thus, this patch convert them to DEFINE_TRACE macro. it help to
> reuse tracepoint definition for other similar usage (i.e. memcg).
> This patch have no functionally change.
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
