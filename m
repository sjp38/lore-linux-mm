Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 67CFB6B13F2
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 05:11:41 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F12E03EE0B5
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:11:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D173345DE99
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:11:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B72A245DE93
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:11:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A65021DB8053
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:11:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 493151DB804E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 19:11:39 +0900 (JST)
Date: Mon, 6 Feb 2012 19:10:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/6] memcg: use new logic for page stat accounting.
Message-Id: <20120206191022.c602bbc2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120206190627.7313ff82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

