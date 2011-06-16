Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BCE556B00E9
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 00:01:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 912723EE0BD
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:01:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7737C45DE68
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:01:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 53F2C45DE61
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:01:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 47B191DB8038
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:01:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FA781DB802C
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 13:01:41 +0900 (JST)
Date: Thu, 16 Jun 2011 12:54:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
Message-Id: <20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

