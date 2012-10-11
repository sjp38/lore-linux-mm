Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CC2336B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 01:19:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E1FCF3EE0AE
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:19:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB4D745DE4E
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:19:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B604145DE52
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:19:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C321DB802F
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:19:47 +0900 (JST)
Received: from G01JPEXCHKW21.g01.fujitsu.local (G01JPEXCHKW21.g01.fujitsu.local [10.0.193.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 65B9A1DB8037
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:19:47 +0900 (JST)
Message-ID: <507656D1.5020703@jp.fujitsu.com>
Date: Thu, 11 Oct 2012 14:19:13 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 0/2] Suppress "Device <device name> does not have a release()
 function" warning
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com

This patch-set is patches to which [1] and [2] are updated
  [1] memory-hotplug: add memory_block_release
  [2] memory-hotplug: add node_device_release
from following patch-set.

https://lkml.org/lkml/2012/9/27/39

So the patch-set version is v2.

v1 -> v2
[PATCH 1/2]
- change subject to Suppress "Device memoryX does not have a release()
  function" warning.
- Add detail information into description
- change function name from release_memory_block() to memory_block_release(),
  because other device release() function is named to <device_name>_release()
[PATCH 2/2]
- change subject to Suppress "Device nodeX does not have a release() function"
  warning.
- Add detail information into description
- Remove memset() to initialize a node struct from node_device_release()
- Add memset() to initialize a node struct into register_node()


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
