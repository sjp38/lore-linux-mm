Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BAECE6B0083
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 00:00:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7A4E73EE0BB
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:00:13 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5758345DE71
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:00:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36A0E45DE6A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:00:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 200EF1DB803A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:00:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C57D81DB8040
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:00:12 +0900 (JST)
Date: Thu, 16 Jun 2011 12:53:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/7] memcg: add memory.scan_stat
Message-Id: <20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

