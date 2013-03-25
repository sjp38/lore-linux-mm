Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx080.postini.com [74.125.246.180])
	by kanga.kvack.org (Postfix) with SMTP id 033FB6B00AA
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 18:36:56 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id t10so489243pdi.20
        for <linux-mm@kvack.org>; Mon, 25 Mar 2013 15:36:56 -0700 (PDT)
Date: Mon, 25 Mar 2013 15:36:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
In-Reply-To: <20130325143400.d226b1f7b64a209b86dd4151@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1303251533530.13531@chino.kir.corp.google.com>
References: <20130318155619.GA18828@sgi.com> <20130321105516.GC18484@gmail.com> <alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com> <20130322072532.GC10608@gmail.com> <20130323152948.GA3036@sgi.com> <CAHGf_=qgsga4Juj8uNnfbmOZYtYhcQbqngbFDWg9=B-1nc1HSw@mail.gmail.com>
 <alpine.DEB.2.02.1303241727420.23613@chino.kir.corp.google.com> <20130325143400.d226b1f7b64a209b86dd4151@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Russ Anderson <rja@sgi.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, 25 Mar 2013, Andrew Morton wrote:

> > Um, defining them in a __meminit function places them in .meminit.data 
> > already.
> 
> I wish it did, but it doesn't.
> 

$ objdump -t mm/page_alloc.o | grep last_start_pfn
0000000000000240 l     O .meminit.data	0000000000000008 last_start_pfn.34345

What version of gcc are you using?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
