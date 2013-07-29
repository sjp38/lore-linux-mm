Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 36A726B003A
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:57:34 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id jz10so3192810veb.26
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:57:33 -0700 (PDT)
Message-ID: <51F6BB3D.6000700@gmail.com>
Date: Mon, 29 Jul 2013 14:58:05 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] arch: mm: do not invoke OOM killer on kernel fault
 OOM
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org> <1374791138-15665-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(7/25/13 6:25 PM), Johannes Weiner wrote:
> Kernel faults are expected to handle OOM conditions gracefully (gup,
> uaccess etc.), so they should never invoke the OOM killer.  Reserve
> this for faults triggered in user context when it is the only option.
> 
> Most architectures already do this, fix up the remaining few.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

OK. but now almost all arch have the same page fault handler. So, I think
we can implement arch generic page fault handler in future. Ah, ok, never
mind if you are not interest.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
