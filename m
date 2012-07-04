Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8080B6B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 23:00:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8AF283EE081
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 12:00:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 73D3C45DE50
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 12:00:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54CAA45DE4F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 12:00:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 47EEC1DB802F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 12:00:27 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E707B1DB8037
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 12:00:26 +0900 (JST)
Message-ID: <4FF3B14E.2090300@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 11:58:22 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 2/2] memcg: remove -ENOMEM at page migration.
References: <4FF3B0DC.5090508@jp.fujitsu.com>
In-Reply-To: <4FF3B0DC.5090508@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

