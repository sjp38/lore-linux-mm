Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id AA7756B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 22:26:40 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id ED6133EE0C5
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:26:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D047945DE5D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:26:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4C6E45DE56
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:26:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A81111DB8052
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:26:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 632A51DB804D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 12:26:37 +0900 (JST)
Date: Fri, 20 Jan 2012 12:25:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v3] memcg: remove unnecessary thp check at page stat
 accounting
Message-Id: <20120120122512.decd06c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

Updated description.
==
