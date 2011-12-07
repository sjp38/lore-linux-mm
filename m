Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AE29C6B004D
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:55:47 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BBA0D3EE0C1
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:55:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CA2A45DE53
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:55:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8224045DE6B
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:55:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1F411DB8057
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:55:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A8B1DB8053
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:55:44 +0900 (JST)
Date: Wed, 7 Dec 2011 09:54:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] oom: add tracepoints for oom_score_adj
Message-Id: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, dchinner@redhat.com

