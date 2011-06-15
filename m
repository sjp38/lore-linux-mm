Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A882B6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 21:56:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E3B8D3EE0C8
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:56:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E64B45DE85
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:56:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 76C2245DE7F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:56:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 695F61DB803B
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:56:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23A2F1DB803E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 10:56:40 +0900 (JST)
Date: Wed, 15 Jun 2011 10:49:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH v6] memcg: fix percpu cached charge draining
 frequency
Message-Id: <20110615104935.ccefc6b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

This is a repleacement for
memcg-fix-percpu-cached-charge-draining-frequency.patch
+
memcg-fix-percpu-cached-charge-draining-frequency-fix.patch


Changelog:
  - removed unnecessary rcu_read_lock()
  - removed a fix for softlimit case (move to another independent patch)
  - make mutex static.
  - applied comment updates from Andrew Morton.

A patch for softlimit will follow this.

==
