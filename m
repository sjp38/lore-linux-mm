Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 76CB89000BD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 04:48:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AF95C3EE0B5
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:48:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 923B945DE7C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:48:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE0D45DE61
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:48:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DD8BE08001
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:48:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BBF31DB802C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:48:51 +0900 (JST)
Date: Tue, 28 Jun 2011 17:41:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [FIX][PATCH 2/3] memcg: fix numa scan information update to be
 triggered by memory event
Message-Id: <20110628174150.6b32e51c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

