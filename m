Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D25B6B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 20:28:44 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u25so60731043qtb.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 17:28:44 -0700 (PDT)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id n46si3515304qtn.12.2016.07.12.17.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 17:28:43 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:26:41 +0900
From: Greg KH <greg@kroah.com>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
Message-ID: <20160713002641.GB17021@kroah.com>
References: <56EFD267.9070609@profihost.ag>
 <20160321133815.GA14188@kroah.com>
 <573AB3BF.3030604@profihost.ag>
 <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
 <CAPerZE_WLYzrALa3YOzC2+NWr--1GL9na8WLssFBNbRsXcYMiA@mail.gmail.com>
 <20160622061356.GW30154@twins.programming.kicks-ass.net>
 <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
 <20160707074232.GS30921@twins.programming.kicks-ass.net>
 <20160711223353.GA8959@kroah.com>
 <20160712131235.GO30154@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160712131235.GO30154@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Campbell Steven <casteven@gmail.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>

On Tue, Jul 12, 2016 at 03:12:35PM +0200, Peter Zijlstra wrote:
> On Mon, Jul 11, 2016 at 03:33:53PM -0700, Greg KH wrote:
> 
> > Oops, this commit does not apply cleanly to 4.6 or 4.4-stable trees.
> > Can someone send me the backported verision that they have tested to
> > work properly so I can queue it up?
> 
> I've never actually been able to reproduce, but the attached patches
> apply, the reject was trivial.
> 
> They seem to compile and boot on my main test rig, but nothing else was
> done but build the next kernel with it.

Thanks for these, now applied.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
