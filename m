Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0E6EF6B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 05:15:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id ACE073EE0B5
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:15:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9306D45DE50
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:15:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C8FB45DE4E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:15:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D0771DB802F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:15:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 174421DB803E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:15:09 +0900 (JST)
Date: Tue, 6 Dec 2011 19:13:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/4] memcg: simplify corner case handling of LRU and
 charge races
Message-Id: <20111206191357.37ae6ac3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111206191211.3be32ccb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
	<20111206191211.3be32ccb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

