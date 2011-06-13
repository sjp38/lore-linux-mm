Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A48E36B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 23:17:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0F9703EE0AE
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:16:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E452F45DF2D
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:16:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C914845DF2A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:16:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB67F1DB803F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:16:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 836FF1DB8038
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:16:53 +0900 (JST)
Date: Mon, 13 Jun 2011 12:09:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 3/5] memcg: clear mm->owner when last possible owner
 leaves
Message-Id: <20110613120951.d4542c5b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, davej@redhat.com

This is Hugh's version.
==
