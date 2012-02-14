Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 25A926B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 22:09:23 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 921B33EE0BD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:09:21 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B36745DE56
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:09:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 51E8045DE4E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:09:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F6A41DB803C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:09:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7B21DB8041
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 12:09:20 +0900 (JST)
Date: Tue, 14 Feb 2012 12:07:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/6 v4] memcg: simplify move_account() check
Message-Id: <20120214120756.0a42f065.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

