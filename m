Date: Sat, 07 Jun 2008 13:40:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3 v2] per-task-delay-accounting: add memory reclaim delay
In-Reply-To: <20080605163111.8877ecb7.kobayashi.kk@ncos.nec.co.jp>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp> <20080605163111.8877ecb7.kobayashi.kk@ncos.nec.co.jp>
Message-Id: <20080607133921.9C3D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Sometimes, application responses become bad under heavy memory load.
> Applications take a bit time to reclaim memory.
> The statistics, how long memory reclaim takes, will be useful to
> measure memory usage.
> 
> This patch adds accounting memory reclaim to per-task-delay-accounting
> for accounting the time of do_try_to_free_pages().

looks good to me.

	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujistu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
