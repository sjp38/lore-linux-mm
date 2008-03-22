Received: by py-out-1112.google.com with SMTP id f47so1922423pye.20
        for <linux-mm@kvack.org>; Sat, 22 Mar 2008 09:43:28 -0700 (PDT)
Message-ID: <2f11576a0803220943l7db994ceyec5fc1ed9ae11424@mail.gmail.com>
Date: Sun, 23 Mar 2008 01:43:26 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [for -mm][PATCH][1/2] page reclaim throttle take3
In-Reply-To: <20080322121528.4efda324@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080322105531.23f2bfdf@bree.surriel.com>
	 <2f11576a0803220901v10a7e3d2j1b7d450b8a100fd3@mail.gmail.com>
	 <20080322121528.4efda324@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

>  >   __alloc_pages_internal  (turn on PF_MEMALLOC)
>  >     +- try_to_free_pages
>  >         +- (skip)
>  >             +- pageout
>  >                 +- (skip)
>  >                     +-  __alloc_pages_internal
>  >
>  > in second __alloc_pages_internal, PF_MEMALLOC populated.
>  > thus bypassed try_to_free_pages.
>  >
>  > Am I misunderstanding anything?
>
>  Look at free_more_memory() in fs/buffer.c

Oh, I see.
thanks.

I will add the mechanism of avoid recursive throttleing problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
