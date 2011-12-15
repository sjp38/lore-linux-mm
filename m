Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 568C16B0201
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 01:08:49 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D8C903EE0BB
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:08:47 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BC58D45DF0B
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:08:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A562445DF0A
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:08:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93AC01DB8051
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:08:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 498011DB805F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:08:47 +0900 (JST)
Date: Thu, 15 Dec 2011 15:07:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] memcg: remove PCG_FILE_MAPPED
Message-Id: <20111215150734.5d21d241.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

