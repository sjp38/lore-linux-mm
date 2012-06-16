Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id B58E96B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:25:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E8CD03EE081
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:25:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D310145DE4F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:25:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD88545DE4E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:25:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE5381DB8037
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:25:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69B651DB802F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:25:28 +0900 (JST)
Message-ID: <4FDC2662.7070702@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 15:23:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V2 1/2] hugetlb: Move all the in use pages to active
 list
References: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org

(2012/06/15 19:31), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> When we fail to allocate pages from the reserve pool, hugetlb
> do try to allocate huge pages using alloc_buddy_huge_page.
> Add these to the active list. We also need to add the huge
> page we allocate when we soft offline the oldpage to active
> list.
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
