Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m94C7aPB022933
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 4 Oct 2008 21:07:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 586922AC027
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:07:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2224312C044
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:07:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C1721DB803A
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:07:36 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BF5BB1DB8038
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 21:07:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH] Report the shmid backing a VMA in maps
In-Reply-To: <20081004205650.CE47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <1223052415-18956-3-git-send-email-mel@csn.ul.ie> <20081004205650.CE47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081004210610.CE4A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat,  4 Oct 2008 21:07:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Adam Litke <agl@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Hi
> 
> I made another hugepage administrating helping patch.
> So, I'd like to hear hugepage folks.

s/folks/folks's opiniton/


yup, I'm really stupid ;-|




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
