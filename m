Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E47AD6B0095
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:30:05 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 843533EE0C3
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:30:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62ACF45DE58
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:30:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 447C145DE5F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:30:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 334261DB8043
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:30:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1471DB803C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:30:03 +0900 (JST)
Message-ID: <50A4B609.5020902@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:29:45 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] memcg: replace __always_inline with plain inline
References: <1352948093-2315-1-git-send-email-glommer@parallels.com> <1352948093-2315-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-5-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

(2012/11/15 11:54), Glauber Costa wrote:
> Following the pattern found in the allocators, where we do our best to
> the fast paths function-call free, all the externally visible functions
> for kmemcg were marked __always_inline.
> 
> It is fair to say, however, that this should be up to the compiler.  We
> will still keep as much of the flag testing as we can in memcontrol.h to
> give the compiler the option to inline it, but won't force it.
> 
> I tested this with 4.7.2, it will inline all three functions anyway when
> compiling with -O2, and will refrain from it when compiling with -Os.
> This seems like a good behavior.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Andrew Morton <akpm@linux-foundation.org>

I'm O.K. with this.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
