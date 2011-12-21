Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B172E6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 05:30:46 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D7103EE081
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:30:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4579645DE54
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BEA845DE52
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DFEC1DB8041
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:30:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C32521DB8037
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:30:44 +0900 (JST)
Date: Wed, 21 Dec 2011 19:29:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v3] memcg: return -EINTR at bypassing try_charge().
Message-Id: <20111221192934.2751f8f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111221172423.5d036cdd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20111221172423.5d036cdd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

Thank you for review.
I'm sorry if my response is delayed.
==
