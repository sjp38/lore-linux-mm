Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B49086B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:50:05 -0400 (EDT)
Date: Tue, 9 Jul 2013 10:50:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-Id: <20130709105032.f9acb85a.akpm@linux-foundation.org>
In-Reply-To: <20130709173242.GA9098@localhost.localdomain>
References: <20130630183349.GA23731@dhcp22.suse.cz>
	<20130701012558.GB27780@dastard>
	<20130701075005.GA28765@dhcp22.suse.cz>
	<20130701081056.GA4072@dastard>
	<20130702092200.GB16815@dhcp22.suse.cz>
	<20130702121947.GE14996@dastard>
	<20130702124427.GG16815@dhcp22.suse.cz>
	<20130703112403.GP14996@dastard>
	<20130704163643.GF7833@dhcp22.suse.cz>
	<20130708125352.GC20149@dhcp22.suse.cz>
	<20130709173242.GA9098@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 9 Jul 2013 21:32:51 +0400 Glauber Costa <glommer@gmail.com> wrote:

> > $ dmesg | grep "blocked for more than"
> > [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > [276962.653097] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > [276962.653940] INFO: task ld:14442 blocked for more than 480 seconds.
> > [276962.654297] INFO: task ld:14962 blocked for more than 480 seconds.
> > [277442.652123] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > [277442.653153] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > [277442.653997] INFO: task ld:14442 blocked for more than 480 seconds.
> > [277442.654353] INFO: task ld:14962 blocked for more than 480 seconds.
> > [277922.652069] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > [277922.653089] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
> > 
> 
> You seem to have switched to XFS. Dave posted a patch two days ago fixing some
> missing conversions in the XFS side. AFAIK, Andrew hasn't yet picked the patch.

I can't find that patch.  Please resend?

There's also "list_lru: fix broken LRU_RETRY behaviour", which I
assume we need?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
