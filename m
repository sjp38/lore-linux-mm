Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2599E6B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 01:21:26 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id a5so133277515vkc.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 22:21:26 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id 44si950752qtn.142.2016.07.08.22.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 22:21:25 -0700 (PDT)
Date: Fri, 8 Jul 2016 22:21:36 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
Message-ID: <20160709052136.GB6330@kroah.com>
References: <56EF15BB.3080509@profihost.ag>
 <20160320214130.GB23920@kroah.com>
 <56EFD267.9070609@profihost.ag>
 <20160321133815.GA14188@kroah.com>
 <573AB3BF.3030604@profihost.ag>
 <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
 <CAPerZE_WLYzrALa3YOzC2+NWr--1GL9na8WLssFBNbRsXcYMiA@mail.gmail.com>
 <20160622061356.GW30154@twins.programming.kicks-ass.net>
 <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
 <20160707074232.GS30921@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707074232.GS30921@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Campbell Steven <casteven@gmail.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 07, 2016 at 09:42:32AM +0200, Peter Zijlstra wrote:
> On Thu, Jul 07, 2016 at 11:20:36AM +1200, Campbell Steven wrote:
> 
> > > commit 8974189222159154c55f24ddad33e3613960521a
> > > Author: Peter Zijlstra <peterz@infradead.org>
> > > Date:   Thu Jun 16 10:50:40 2016 +0200
> 
> > Since these early reports from Stefan and I it looks like it's been
> > hit but alot more folks now so I'd like to ask what the process is for
> > getting this backported into 4.6, 4.5 and 4.4 as in our testing all
> > those versions for their latest point release seem to have the same
> > problem.
> 
> I think this should do; Greg is on Cc and will mark the commit
> somewhere. It is already in Linus' tree and should indeed be sufficient.
> 
> It has a Fixes tag referring the commit that introduced it, which IIRC
> is somewhere around v4.2.
> 
> Greg, anything else required?

Nope, that should be fine.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
