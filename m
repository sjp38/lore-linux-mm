Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1846B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 22:28:15 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9E62C3EE0C0
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:28:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8416E45DEA6
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CAFD45DE9E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:28:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FAC51DB803C
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:28:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AF211DB8038
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:28:13 +0900 (JST)
Date: Fri, 20 Jan 2012 12:26:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v3] memcg: remove PCG_CACHE page_cgroup flag
Message-Id: <20120120122658.1b14b512.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

I think this version is much simplified.

==
