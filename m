Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 638226B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 08:40:13 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so9084574wev.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 05:40:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ce3si19919404wib.0.2015.01.26.05.40.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 05:40:11 -0800 (PST)
Date: Mon, 26 Jan 2015 08:37:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150126133712.GB9738@cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <alpine.DEB.2.11.1501231419420.11767@gentwo.org>
 <54C2B01D.4070303@roeck-us.net>
 <alpine.DEB.2.11.1501231508020.7871@gentwo.org>
 <20150124071623.GA17705@phnom.home.cmpxchg.org>
 <109548.1422221788@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <109548.1422221788@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Christoph Lameter <cl@linux.com>, Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Sun, Jan 25, 2015 at 04:36:28PM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Sat, 24 Jan 2015 02:16:23 -0500, Johannes Weiner said:
> 
> > I would generally agree, but this code, which implements a userspace
> > interface, is already grotesquely inefficient and heavyhanded.  It's
> > also superseded in the next release, so we can just keep this simple
> > at this point.
> 
> Wait, what?  Userspace interface that's superceded in the next release?

The existing interface and its implementation are going to remain in
place, obviously, we can't break userspace.  But the semantics are
ill-defined and the implementation bad to a point where we decided to
fix both by adding a second interface and encouraging users to switch.

Now if a user were to report that these off-node allocations are
actually creating problems in real life I would fix it.  But I'm
fairly certain that remote access costs are overshadowed by the
reclaim stalls this mechanism creates.

So what I was trying to say above is that I don't see a point in
complicating the v1 implementation for a questionable minor
optimization when v2 is already being added to address much more
severe shortcomings in v1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
