Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BD0636B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:34:39 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id n3so2847068wiv.1
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:34:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ew1si2503036wib.36.2014.09.10.07.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 07:34:38 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:33:52 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: Trinity and mbind flags (WAS: Re: mm: BUG in unmap_page_range)
Message-ID: <20140910143352.GB10785@redhat.com>
References: <20140827152622.GC12424@suse.de>
 <540127AC.4040804@oracle.com>
 <54082B25.9090600@oracle.com>
 <20140908171853.GN17501@suse.de>
 <540DEDE7.4020300@oracle.com>
 <20140909213309.GQ17501@suse.de>
 <540F7D42.1020402@oracle.com>
 <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
 <20140910124732.GT17501@suse.de>
 <54105F28.1000506@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54105F28.1000506@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Wed, Sep 10, 2014 at 10:24:40AM -0400, Sasha Levin wrote:
 > On 09/10/2014 08:47 AM, Mel Gorman wrote:
 > > That site should have checked PROT_NONE but it can't be the same bug
 > > that trinity is seeing. Minimally trinity is unaware of MPOL_MF_LAZY
 > > according to git grep of the trinity source.
 > 
 > Actually, if I'm reading it correctly I think that Trinity handles mbind()
 > calls wrong. It passes the wrong values for mode flags and actual flags.

Ugh, I think you're right.  I misinterpreted the man page that mentions
that flags like MPOL_F_STATIC_NODES/RELATIVE_NODES are OR'd with the
mode, and instead dumped those flags into .. the flags field.

So the 'flags' argument it generates is crap, because I didn't add
any of the actual correct values.

I'll fix it up, though if it's currently finding bugs, you might want
to keep the current syscalls/mbind.c for now.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
