Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2359D9000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 04:50:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C32FA3EE081
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 17:50:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A336745DF4E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 17:50:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 799DB45DF4B
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 17:50:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 642B41DB8058
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 17:50:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2034C1DB8050
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 17:50:06 +0900 (JST)
Date: Mon, 27 Jun 2011 17:42:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] Fix direct softlimit reclaim to be called in memcg
 limit path.
Message-Id: <20110627174205.ccee1027.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>

