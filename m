Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 957D86B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 03:42:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so20722162pfb.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 00:42:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f15si2815452pap.97.2016.07.07.00.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 00:42:33 -0700 (PDT)
Date: Thu, 7 Jul 2016 09:42:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
Message-ID: <20160707074232.GS30921@twins.programming.kicks-ass.net>
References: <56EDD206.3070202@suse.cz>
 <56EF15BB.3080509@profihost.ag>
 <20160320214130.GB23920@kroah.com>
 <56EFD267.9070609@profihost.ag>
 <20160321133815.GA14188@kroah.com>
 <573AB3BF.3030604@profihost.ag>
 <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
 <CAPerZE_WLYzrALa3YOzC2+NWr--1GL9na8WLssFBNbRsXcYMiA@mail.gmail.com>
 <20160622061356.GW30154@twins.programming.kicks-ass.net>
 <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Campbell Steven <casteven@gmail.com>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Greg KH <greg@kroah.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 07, 2016 at 11:20:36AM +1200, Campbell Steven wrote:

> > commit 8974189222159154c55f24ddad33e3613960521a
> > Author: Peter Zijlstra <peterz@infradead.org>
> > Date:   Thu Jun 16 10:50:40 2016 +0200

> Since these early reports from Stefan and I it looks like it's been
> hit but alot more folks now so I'd like to ask what the process is for
> getting this backported into 4.6, 4.5 and 4.4 as in our testing all
> those versions for their latest point release seem to have the same
> problem.

I think this should do; Greg is on Cc and will mark the commit
somewhere. It is already in Linus' tree and should indeed be sufficient.

It has a Fixes tag referring the commit that introduced it, which IIRC
is somewhere around v4.2.

Greg, anything else required?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
