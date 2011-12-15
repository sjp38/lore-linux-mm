Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DCD5A6B01F8
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 01:09:34 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7A90A3EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:09:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61BBD45DE52
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:09:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48BB945DE4F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:09:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B4DD1DB8041
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:09:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF0CC1DB803B
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:09:32 +0900 (JST)
Date: Thu, 15 Dec 2011 15:08:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/5] memcg: remove PCG_CACHE bit
Message-Id: <20111215150822.7b609f89.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

