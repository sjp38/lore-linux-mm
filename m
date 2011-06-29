Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25E8A6B00EA
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 06:10:45 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 106F03EE081
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 19:10:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB2E45DED8
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 19:10:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2D9345DED0
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 19:10:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C1CBE1DB8044
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 19:10:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FC371DB8041
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 19:10:40 +0900 (JST)
Date: Wed, 29 Jun 2011 19:03:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

This is onto 3 patches I posted yesterday.
I'm sorry I once got Acks in v1 but refleshed totally. 
==
