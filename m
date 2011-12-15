Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 05B646B0201
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 01:06:35 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9CE6F3EE0C0
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:06:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 782DF45DF0B
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:06:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A73F45DF03
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:06:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 454321DB8051
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:06:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D07A51DB8056
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:06:32 +0900 (JST)
Date: Thu, 15 Dec 2011 15:05:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 1/5] memcg: simplify account moving check
Message-Id: <20111215150522.180da280.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

