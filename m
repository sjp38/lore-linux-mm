Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89DB86B00FC
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 05:01:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 850BC3EE0BB
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:01:17 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C4B945DE69
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:01:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55DDE45DE6A
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:01:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 499991DB802C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:01:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A7A31DB8038
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 18:01:17 +0900 (JST)
Date: Tue, 28 Jun 2011 17:54:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3] mm: preallocate page before lock_page() at filemap COW
Message-Id: <20110628175414.6a316402.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

