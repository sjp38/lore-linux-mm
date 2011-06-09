Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6036B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 06:17:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6C7453EE0BD
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:17:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 50EC545DED2
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:17:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 386F345DED1
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:17:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 12C6E1DB8043
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:17:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95D431DB8041
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:17:47 +0900 (JST)
Date: Thu, 9 Jun 2011 19:10:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] A scan node selection logic for memcg rather than
 round-robin.
Message-Id: <20110609191031.483daba5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>


A scan node selection logic for memcg rather than round-robin.

This patch is what I'm testing now but I don't have big NUMA.
please review if you have time. This is against linux-3.0-rc2.

==
