Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G6A0JH014875
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 15:10:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18F991B801E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:10:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E579D2DC015
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:09:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A82101DB8038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:09:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5692D1DB803F
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:09:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081016102752.9886.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081016150627.582F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 15:09:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes, 

>                          2.6.27    mmotm-1010
>    ==============================================================
>    mm_sync_madv_cp       6:14      6:02         (min:sec)
>    dbench throughput     12.1507   14.6273      (MB/s)
>    dbench latency        33046     21779        (ms)
> 
> 
>    So, throughput improvement is relativily a bit, but latency improvement is much.
>    Then, I think the patch can improve "larege file copy (e.g. backup operation)
>    attacks desktop latency" problem.

That means, 
	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	Ack-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
