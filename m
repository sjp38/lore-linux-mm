Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 66B5B6B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 17:59:36 -0400 (EDT)
Date: Thu, 1 Aug 2013 17:59:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/6] arch: mm: do not invoke OOM killer on kernel fault
 OOM
Message-ID: <20130801215924.GO715@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-3-git-send-email-hannes@cmpxchg.org>
 <51F6BB3D.6000700@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F6BB3D.6000700@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 29, 2013 at 02:58:05PM -0400, KOSAKI Motohiro wrote:
> (7/25/13 6:25 PM), Johannes Weiner wrote:
> > Kernel faults are expected to handle OOM conditions gracefully (gup,
> > uaccess etc.), so they should never invoke the OOM killer.  Reserve
> > this for faults triggered in user context when it is the only option.
> > 
> > Most architectures already do this, fix up the remaining few.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> OK. but now almost all arch have the same page fault handler. So, I think
> we can implement arch generic page fault handler in future. Ah, ok, never
> mind if you are not interest.

Well, I'm already working towards it ;-) Still a long way to go,
though to fully replace them with generic code...

> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
