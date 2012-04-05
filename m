Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 347EE6B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 10:49:57 -0400 (EDT)
Date: Thu, 5 Apr 2012 07:49:50 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] memcg swap: use mem_cgroup_uncharge_swap fix
Message-ID: <20120405144949.GA17770@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
 <alpine.DEB.2.00.1204042017520.8789@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204042017520.8789@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed 04-04-12 20:19:18, David Rientjes wrote:
> linux-next fails with this 
> 
> mm/memcontrol.c: In function '__mem_cgroup_commit_charge_swapin':
> mm/memcontrol.c:2837: error: implicit declaration of function 'mem_cgroup_uncharge_swap'
> 
> if CONFIG_SWAP is disabled.  Fix it.

Although this is correct maybe it would be better to move the definition
outside the CONFIG_SWAP to prevent from duplication
What do you think about the following?
---
