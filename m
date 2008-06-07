Date: Sat, 07 Jun 2008 13:46:00 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3 v2] per-task-delay-accounting: update document and getdelays.c for memory reclaim
In-Reply-To: <20080605163338.8880eb7f.kobayashi.kk@ncos.nec.co.jp>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp> <20080605163338.8880eb7f.kobayashi.kk@ncos.nec.co.jp>
Message-Id: <20080607134438.9C43.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Update document and make getdelays.c show delay accounting for memory reclaim.
> 
> For making a distinction between "swapping in pages" and "memory reclaim"
> in getdelays.c, MEM is changed to SWAP.
> 
> Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>

looks good to me.

but I don't know s/MEM/SWAP/ renaming is good or bad.
You should hear delayacct developer opinion. IMHO.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
