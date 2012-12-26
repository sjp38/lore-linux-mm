Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 841DB6B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:38:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2E1033EE0BC
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:38:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 138B945DE6B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:38:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECB7E45DE67
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:38:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1527E38002
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:38:05 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 870D81DB8044
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:38:05 +0900 (JST)
Message-ID: <50DA70E0.3050704@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 12:37:04 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 05/14] memory-hotplug: introduce new function arch_remove_memory()
 for removing page table depends on architecture
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-6-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
> 
> For removing memory, we need to remove page table. But it depends
> on architecture. So the patch introduce arch_remove_memory() for
> removing page table. Now it only calls __remove_pages().
> 
> Note: __remove_pages() for some archtecuture is not implemented
>        (I don't know how to implement it for s390).
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

Then, remove code will be symetric to add codes.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
