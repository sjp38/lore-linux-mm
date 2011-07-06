Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51BD49000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 01:25:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D9303EE0C0
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:25:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DE2E45DE62
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:25:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0DB445DE5A
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:25:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C94681DB8053
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:25:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8032DE08002
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:25:41 +0900 (JST)
Date: Wed, 6 Jul 2011 14:18:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v5
Message-Id: <20110706141825.2df34560.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701161051.0ab237c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630130134.63a1dd37.akpm@linux-foundation.org>
	<20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630180653.1df10f38.akpm@linux-foundation.org>
	<20110701101624.a10b7e34.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701103007.8110f130.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701161051.0ab237c5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 1 Jul 2011 16:10:51 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Sorry, this seems still buggy. I'll send a new one in the next week :(
> 

tested with allnoconfig, allyesconfig, CONFIG_SWAP=y/n,
CONFIG_CGROUP_MEM_RES_CTLR=y/n

Patch is onto mmotm-0630.

==
