Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 892A9900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:35:09 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p3FNZ65B008757
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:35:06 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe17.cbf.corp.google.com with ESMTP id p3FNZ4Df028700
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:35:04 -0700
Received: by pwj8 with SMTP id 8so1892922pwj.41
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:35:04 -0700 (PDT)
Date: Fri, 15 Apr 2011 16:35:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mempolicy: reduce references to the current
In-Reply-To: <1302847688-8076-1-git-send-email-namhyung@gmail.com>
Message-ID: <alpine.DEB.2.00.1104151634050.3847@chino.kir.corp.google.com>
References: <BANLkTinDFrbUNPnUmed2aBTu1_QHFQie-w@mail.gmail.com> <1302847688-8076-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Apr 2011, Namhyung Kim wrote:

> Remove duplicated reference to the 'current' task using a local
> variable. Since refering the current can be a burden, it'd better
> cache the reference, IMHO. At least this saves some bytes on x86_64.
> 
>   $ size mempolicy-{old,new}.o
>      text    data    bss     dec     hex filename
>     25203    2448   9176   36827    8fdb mempolicy-old.o
>     25136    2448   9184   36768    8fa0 mempolicy-new.o
> 

So this is the opposite of what Andrew did in c06b1fca18c3 
(mm/page_alloc.c: don't cache `current' in a local) for the page 
allocator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
