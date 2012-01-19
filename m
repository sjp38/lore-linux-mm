Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 152DE6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:16:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A96D63EE0B6
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:16:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DE5645DE54
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:16:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 726E945DE4D
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:16:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A4261DB8041
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:16:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F27C1DB8037
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:16:03 +0900 (JST)
Date: Thu, 19 Jan 2012 16:14:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: remove unnecessary thp check at page stat accounting
Message-Id: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

Thank you very much for reviewing previous RFC series.
This is a patch against memcg-devel and linux-next (can by applied without HUNKs).

==
