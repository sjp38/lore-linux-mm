Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 815856B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 12:06:56 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so25378323pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 09:06:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qp7si58800410pbc.93.2015.10.07.09.06.55
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 09:06:55 -0700 (PDT)
Date: Wed, 7 Oct 2015 09:06:52 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151007160652.GK26924@tassilo.jf.intel.com>
References: <560ABE86.9050508@gmail.com>
 <20150930114255.13505.2618.stgit@canyon>
 <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
 <20151002114118.75aae2f9@redhat.com>
 <20151002154039.69f82bdc@redhat.com>
 <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
 <20151005212639.35932b6c@redhat.com>
 <20151005212045.GG26924@tassilo.jf.intel.com>
 <20151006010703.09e2f0ff@redhat.com>
 <20151007143120.7068416d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151007143120.7068416d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>

> My specific CPU (i7-4790K @ 4.00GHz) unfortunately seems to have
> limited "Frontend" support. E.g. 
> 
>  # perf record -g -a -e stalled-cycles-frontend
>  Error:
>  The stalled-cycles-frontend event is not supported.
> 
> And AFAIK icache misses are part of "frontend".

Ignore stalled-cycles-frontend. It is very unreliable and has never worked right.
toplev gives you much more reliable output.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
