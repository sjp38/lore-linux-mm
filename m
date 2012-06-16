Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 237706B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:26:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AD92A3EE081
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:26:56 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9806B45DEA6
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:26:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80B1345DE9E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:26:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 750441DB803B
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:26:56 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FD901DB8038
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:26:56 +0900 (JST)
Message-ID: <4FDC26BB.80806@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 15:24:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] hugetlb/cgroup: Assign the page hugetlb cgroup when
 we move the page to active list.
References: <87k3z8nb3h.fsf@skywalker.in.ibm.com> <1339754902-17779-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339754902-17779-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339754902-17779-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org

(2012/06/15 19:08), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> page's hugetlb cgroup assign and moving to active list should happen with
> hugetlb_lock held. Otherwise when we remove the hugetlb cgroup we would
> iterate the active list and will find page with NULL hugetlb cgroup values.
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
