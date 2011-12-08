Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 223ED6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:19:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 108BC3EE0B5
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:19:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D44A45DE5B
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:19:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7074A45DE50
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:19:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B4A2E08003
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:19:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EAC8B1DB803F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:19:55 +0900 (JST)
Date: Thu, 8 Dec 2011 16:18:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH v2] add mem_cgroup_replace_page_cache.
Message-Id: <20111208161829.b6101de6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111207111455.GA18249@tiehlicka.suse.cz>
References: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
	<20111207111455.GA18249@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Wed, 7 Dec 2011 12:14:55 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Other than that looks ok.
> 

Thank you for review. v2 here. This patch is for the latest linux-next.
==
