Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id DD8B16B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 03:25:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1D9513EE0BC
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:25:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B97E645DE68
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:25:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A036645DE4D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:25:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89FCF1DB8040
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:25:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 365A8EF8001
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 17:25:36 +0900 (JST)
Date: Wed, 21 Dec 2011 17:24:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2] memcg: return -EINTR at bypassing try_charge().
Message-Id: <20111221172423.5d036cdd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

How about this ?
--
