Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5B8F06B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 17:16:12 -0400 (EDT)
Date: Mon, 5 Aug 2013 14:16:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-Id: <20130805141609.777a0d6dee55091f6981c39b@linux-foundation.org>
In-Reply-To: <20130805210128.GA2772@paralelels.com>
References: <1375718980-22154-1-git-send-email-avagin@openvz.org>
	<20130805130530.fd38ec4866ba7f1d9a400218@linux-foundation.org>
	<20130805210128.GA2772@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@parallels.com>
Cc: Andrey Vagin <avagin@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, stable@vger.kernel.org

On Tue, 6 Aug 2013 01:01:28 +0400 Andrew Vagin <avagin@parallels.com> wrote:

> On Mon, Aug 05, 2013 at 01:05:30PM -0700, Andrew Morton wrote:
> > On Mon,  5 Aug 2013 20:09:40 +0400 Andrey Vagin <avagin@openvz.org> wrote:
> > 
> > > struct memcg_cache_params has a union. Different parts of this union
> > > are used for root and non-root caches. A part with destroying work is
> > > used only for non-root caches.
> > > 
> > > I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
> > > didn't notice this one.
> > > 
> > > Cc: <stable@vger.kernel.org>    [3.9.x]
> > 
> > hm, why the cc:stable?
> 
> Because this patch fixes the kernel panic:
> 
> [   46.848187] BUG: unable to handle kernel paging request at 000000fffffffeb8
> [   46.849026] IP: [<ffffffff811a484c>] kmem_cache_destroy_memcg_children+0x6c/0xc0
> [   46.849092] PGD 0
> [   46.849092] Oops: 0000 [#1] SMP

OK, pretty soon we'll have a changelog!

What does one do to trigger this oops?  The bug has been there since
3.9, so the means-of-triggering must be quite special?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
