Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC236B0082
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 14:49:35 -0400 (EDT)
Received: by wiwl15 with SMTP id l15so205863wiw.0
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 11:49:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si2666627wiv.123.2015.03.12.11.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Mar 2015 11:49:33 -0700 (PDT)
Date: Thu, 12 Mar 2015 18:49:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150312184925.GH3406@suse.de>
References: <20150307163657.GA9702@gmail.com>
 <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
 <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
 <20150309112936.GD26657@destitution>
 <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
 <20150309191943.GF26657@destitution>
 <CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
 <20150312131045.GE3406@suse.de>
 <CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 12, 2015 at 09:20:36AM -0700, Linus Torvalds wrote:
> On Thu, Mar 12, 2015 at 6:10 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > I believe you're correct and it matches what was observed. I'm still
> > travelling and wireless is dirt but managed to queue a test using pmd_dirty
> 
> Ok, thanks.
> 
> I'm not entirely happy with that change, and I suspect the whole
> heuristic should be looked at much more (maybe it should also look at
> whether it's executable, for example), but it's a step in the right
> direction.
> 

I can follow up when I'm back in work properly. As you have already pulled
this in directly, can you also consider pulling in "mm: thp: return the
correct value for change_huge_pmd" please? The other two patches were very
minor can be resent through the normal paths later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
