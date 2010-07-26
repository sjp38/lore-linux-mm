Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8093C6B02A5
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:23:16 -0400 (EDT)
Received: by iwn2 with SMTP id 2so3237337iwn.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 03:23:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com>
Date: Mon, 26 Jul 2010 15:53:13 +0530
Message-ID: <AANLkTi=sVdkkHm8wvjRC4gQUjsKBm1TiLfvxvVBEbbAn@mail.gmail.com>
Subject: Re: [PATCH 0/4] memcg reclaim tracepoint v2
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 8:32 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Recently, Mel Gorman added some vmscan tracepoint. but they can't
> trace memcg. So, This patch series does.
>

The overall series looks good to me, acking the approach and the need
for these patches

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
