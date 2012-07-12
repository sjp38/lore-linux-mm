Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 4B5A56B005C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:33:44 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3577666pbb.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 19:33:43 -0700 (PDT)
Date: Wed, 11 Jul 2012 19:33:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
In-Reply-To: <20120711235504.GA5204@bbox>
Message-ID: <alpine.DEB.2.00.1207111930020.9370@chino.kir.corp.google.com>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org> <20120709170856.ca67655a.akpm@linux-foundation.org> <20120710002510.GB5935@bbox> <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com> <20120711022304.GA17425@bbox>
 <alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com> <4FFD15B2.6020001@kernel.org> <alpine.DEB.2.00.1207111337430.3635@chino.kir.corp.google.com> <CAEwNFnB1Z92f22ms=EsBEOOY4Q_JRA8rMPUvQmoqik7rt-EgcQ@mail.gmail.com>
 <alpine.DEB.2.00.1207111556190.24516@chino.kir.corp.google.com> <20120711235504.GA5204@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, 12 Jul 2012, Minchan Kim wrote:

> Agreed and that's why I suggested following patch.
> It's not elegant but at least, it could attract interest of configuration
> people and they could find a regression during test phase.
> This description could be improved later by writing new documenation which
> includes more detailed story and method for capturing high order allocation
> by ftrace once we see regression report.
> 
> At the moment, I would like to post this patch, simply.
> (Of course, I hope fluent native people will correct a sentence. :) )
> 
> Any objections, Andrew, David?
> 

There are other config options like CONFIG_SLOB that are used for a very 
small memory footprint on systems like this.  We used to have 
CONFIG_EMBEDDED to suggest options like this but that has since been 
renamed as CONFIG_EXPERT and has become obscured.

If size is really the only difference, I would think that people who want 
the smallest kernel possible would be doing allnoconfig and then 
selectively enabling what they need, so defconfig isn't really relevant 
here.  And it's very difficult for an admin to know whether or not they 
"care about high-order allocations."

I'd reconsider disabling compaction by default unless there are other 
considerations that haven't been mentioned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
