Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m458DS8e029041
	for <linux-mm@kvack.org>; Mon, 5 May 2008 04:13:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m458Cg2v260454
	for <linux-mm@kvack.org>; Mon, 5 May 2008 04:12:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m458Cffu013558
	for <linux-mm@kvack.org>; Mon, 5 May 2008 04:12:42 -0400
Date: Mon, 5 May 2008 01:12:39 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [-mm][PATCH 1/5] fix overflow problem of do_try_to_free_page()
Message-ID: <20080505081239.GB22105@us.ibm.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080504215331.8F55.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080504215331.8F55.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04.05.2008 [21:55:57 +0900], KOSAKI Motohiro wrote:
> this patch is not part of reclaim throttle series.
> it is merely hotfixs.
> 
> ---------------------------------------
> "Smarter retry of costly-order allocations" patch series change 
> behaver of do_try_to_free_pages().
> but unfortunately ret variable type unchanged.
> 
> thus, overflow problem is possible.
> 
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Nishanth Aravamudan <nacc@us.ibm.com>

Eep, sorry -- my original version had used -EAGAIN to indicate a special
condition, but this was removed before the final patch. Thanks for the
catch.

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Should go upstream, as well.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
