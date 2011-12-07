Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 650696B0080
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:56:20 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B26B43EE0B6
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:56:18 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 98DC945DEB6
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:56:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7370445DEA6
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:56:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 640581DB803B
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:56:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C76781DB803E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:56:17 +0900 (JST)
Date: Wed, 7 Dec 2011 10:55:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v3] oom: add tracepoints for oom_score_adj
Message-Id: <20111207105511.68fb0387.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, dchinner@redhat.com

Fixed compile warning and use TRACE_EVENT_CONDITION() rather than open-coded 'if'
==
