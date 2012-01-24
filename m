Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B1A436B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 22:17:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AB1CB3EE0C0
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:17:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89EF245DE69
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:17:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EB9445DD74
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:17:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA20E08001
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:17:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 086641DB8038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:17:53 +0900 (JST)
Date: Tue, 24 Jan 2012 12:16:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4] memcg: remove PCG_CACHE page_cgroup flag
Message-Id: <20120124121636.115f1cf0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120120084545.GC9655@tiehlicka.suse.cz>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20120120122658.1b14b512.kamezawa.hiroyu@jp.fujitsu.com>
	<20120120084545.GC9655@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>


> Can we make this anon as well?

I'm sorry for long RTT. version 4 here.
==
