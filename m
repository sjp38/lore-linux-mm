Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id D49FD6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 15:00:08 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1511818pbb.36
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 12:00:08 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id a3si2050268pay.307.2014.03.13.12.00.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 12:00:07 -0700 (PDT)
Message-ID: <1394737202.2452.8.camel@buesod1.americas.hpqcorp.net>
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 13 Mar 2014 12:00:02 -0700
In-Reply-To: <531F8C3A.1040502@oracle.com>
References: <531F6689.60307@oracle.com>
				<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
			 <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
			 <531F75D1.3060909@oracle.com>
		 <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
		 <531F79F7.5090201@oracle.com>
	 <1394574323.2786.45.camel@buesod1.americas.hpqcorp.net>
	 <531F8C3A.1040502@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2014-03-11 at 18:20 -0400, Sasha Levin wrote:
> On 03/11/2014 05:45 PM, Davidlohr Bueso wrote:
> > On Tue, 2014-03-11 at 17:02 -0400, Sasha Levin wrote:
> >> >On 03/11/2014 04:47 PM, Davidlohr Bueso wrote:
> >>>> > >>Bingo! With the above patch:
> >>>>> > >> >
> >>>>> > >> >[  243.565794] kernel BUG at mm/vmacache.c:76!
> >>>>> > >> >[  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >>>>> > >> >[  243.568048] Dumping ftrace buffer:
> >>>>> > >> >[  243.568740]    (ftrace buffer empty)
> >>>>> > >> >[  243.569481] Modules linked in:
> >>>>> > >> >[  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143
> >>> > >and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
> >>> > >the root cause it the same as Fengguang's report.
> >> >
> >> >The BUG still happens without DEBUG_PAGEALLOC.
> > Any idea what trinity itself is doing?
> >
> > Could you add the following, I just want to make sure the bug isn't
> > being caused by an overflow:
> 
> Not hitting that WARN.

Sasha, could you please try the following patch:
https://lkml.org/lkml/2014/3/13/312

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
