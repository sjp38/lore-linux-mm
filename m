Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 302D16B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 03:30:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7BF1C3EE081
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:30:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63CFC45DEB2
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:30:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B36745DE9E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:30:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 349371DB8038
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:30:22 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2B4B1DB803C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:30:21 +0900 (JST)
Message-ID: <4FDC358F.6020905@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 16:28:15 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v2
References: <1339542816-21663-1-git-send-email-andi@firstfloor.org>
In-Reply-To: <1339542816-21663-1-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

(2012/06/13 8:13), Andi Kleen wrote:
> From: Andi Kleen<ak@linux.intel.com>
> 
> There was some desire in large applications using MAP_HUGETLB/SHM_HUGETLB
> to use 1GB huge pages on some mappings, and stay with 2MB on others. This
> is useful together with NUMA policy: use 2MB interleaving on some mappings,
> but 1GB on local mappings.
> 
> This patch extends the IPC/SHM syscall interfaces slightly to allow specifying
> the page size.
> 
> It borrows some upper bits in the existing flag arguments and allows encoding
> the log of the desired page size in addition to the *_HUGETLB flag.
> When 0 is specified the default size is used, this makes the change fully
> compatible.
> 
> Extending the internal hugetlb code to handle this is straight forward. Instead
> of a single mount it just keeps an array of them and selects the right
> mount based on the specified page size.
> 
> I also exported the new flags to the user headers
> (they were previously under __KERNEL__). Right now only symbols
> for x86 and some other architecture for 1GB and 2MB are defined.
> The interface should already work for all other architectures
> though.
> 
> v2: Port to new tree. Fix unmount.
> Signed-off-by: Andi Kleen<ak@linux.intel.com>

I like this.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, do you have any plan to implement 1GB page allocator ?
I wonder recent contiguous-memory-allocator works can be used for...




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
