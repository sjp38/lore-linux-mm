Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A96A66B00E5
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 21:44:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C3AF53EE0BC
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:44:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA63345DE56
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:44:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 949CC45DE50
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:44:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 778C81DB8041
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:44:45 +0900 (JST)
Received: from g01jpexchyt30.g01.fujitsu.local (g01jpexchyt30.g01.fujitsu.local [10.128.193.113])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16FF01DB8037
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:44:45 +0900 (JST)
Message-ID: <506CE9F5.8020809@jp.fujitsu.com>
Date: Thu, 4 Oct 2012 10:44:21 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/2] acpi,memory-hotplug : remove memory device by acpi_bus_remove()
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: len.brown@intel.com, wency@cn.fujitsu.com

The patch-set was divided from following thread's patch-set.

https://lkml.org/lkml/2012/9/5/201

If you want to know the reason, please read following thread.

https://lkml.org/lkml/2012/10/2/83

The patch exports "acpi_bus_remove()" for removing a acpi device from a
acpi bus at memory hot plug.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
