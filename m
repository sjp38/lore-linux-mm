Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F15046B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:31:08 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y6so41102874lff.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 07:31:08 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id v125si19797723wmd.15.2016.09.19.07.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 07:31:07 -0700 (PDT)
Date: Mon, 19 Sep 2016 07:31:06 -0700
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: More OOM problems
Message-ID: <20160919143106.GX5871@two.firstfloor.org>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <87twdc4rzs.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 19, 2016 at 08:37:36AM -0500, Christoph Lameter wrote:
> On Sun, 18 Sep 2016, Andi Kleen wrote:
> 
> > > Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
> > > hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
> > > OOM, though. Guess not...
> >
> > It's already trying to do that, perhaps just some flags need to be
> > changed?
> 
> SLUB tries order-N and falls back to order 0 on failure.

Right it tries, but Linus apparently got an OOM in the order-N
allocation. So somehow the flag combination that it passes first
is not preventing the OOM killer.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
