Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 22C576B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 22:48:33 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 697563EE0C2
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:48:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E96245DE9D
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:48:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A1BE45DE9C
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:48:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 063FCE08003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:48:31 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC5DD1DB8037
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 12:48:30 +0900 (JST)
Message-ID: <50DA7357.109@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 12:47:35 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 07/14] memory-hotplug: move pgdat_resize_lock into
 sparse_remove_one_section()
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-8-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> In __remove_section(), we locked pgdat_resize_lock when calling
> sparse_remove_one_section(). This lock will disable irq. But we don't need
> to lock the whole function. If we do some work to free pagetables in
> free_section_usemap(), we need to call flush_tlb_all(), which need
> irq enabled. Otherwise the WARN_ON_ONCE() in smp_call_function_many()
> will be triggered.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

If this is a bug fix, call-trace in your log and BUGFIX or -fix- in patch title
will be appreciated, I think.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
