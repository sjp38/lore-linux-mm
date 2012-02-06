Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C0EE96B13F3
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 05:12:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3F6583EE0C1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:12:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2637945DE95
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:12:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CDD245DE94
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:12:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F11DB1DB8048
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:12:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8E221DB8052
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:12:13 +0900 (JST)
Date: Mon, 6 Feb 2012 19:10:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/6] memcg: remove PCG_FILE_MAPPED
Message-Id: <20120206191054.9865eec8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

