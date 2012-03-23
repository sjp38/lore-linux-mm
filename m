Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 02C546B0092
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 17:09:20 -0400 (EDT)
Date: Fri, 23 Mar 2012 14:09:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg swap: mem_cgroup_move_swap_account never needs
 fixup
Message-Id: <20120323140918.804b3860.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
References: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 23 Mar 2012 13:51:26 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> I believe it's now agreed that an 81-column line is better left unsplit.

There's always a way ;)

> +			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {

The code sometimes uses "mem_cgroup" and sometimes "memcg".  I don't
think the _, r, o, u and p add any value...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
