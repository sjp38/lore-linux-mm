Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id mB4I1gft532962
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 18:01:42 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB4I1gbK2470048
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 18:01:42 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB4I1fpg007457
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 18:01:41 GMT
Subject: Re: [PATCH] mm: remove UP version lru_add_drain_all()
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20081204110013.1D62.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <1228342567.13111.11.camel@nimitz>
	 <20081204093143.390afa9f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081204110013.1D62.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 04 Dec 2008 19:01:39 +0100
Message-Id: <1228413699.18010.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-12-04 at 11:14 +0900, KOSAKI Motohiro wrote:
> Then this ifdef is not valueable.
> simple removing is better.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Thanks, works for me.

Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
