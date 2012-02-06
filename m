Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 2F7C26B13F2
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 05:10:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C6B223EE0C1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:10:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEF0F45DEDC
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:10:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95E5445DEEC
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:10:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 83B831DB8040
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:10:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A13F1DB803E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:10:25 +0900 (JST)
Date: Mon, 6 Feb 2012 19:09:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 2/6 v3]  memcg: remove
 EXPORT_SYMBOL(mem_cgroup_update_page_stat)
Message-Id: <20120206190907.4167f834.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Michal pointed out this.
