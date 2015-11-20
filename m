Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 37D036B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 18:23:12 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so129973705pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:23:12 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id hu9si2242453pbc.87.2015.11.20.15.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 15:23:11 -0800 (PST)
Received: by padhx2 with SMTP id hx2so130013306pad.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:23:11 -0800 (PST)
Date: Fri, 20 Nov 2015 15:23:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory exhaustion testing?
In-Reply-To: <20151120140916.33ec7896@redhat.com>
Message-ID: <alpine.DEB.2.10.1511201522150.10092@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com> <alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com> <20151116152440.101ea77d@redhat.com> <20151117142120.494947f9@redhat.com> <alpine.DEB.2.10.1511191239001.7151@chino.kir.corp.google.com>
 <20151120140916.33ec7896@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Fri, 20 Nov 2015, Jesper Dangaard Brouer wrote:

> > Any chance you could proffer some of your scripts in the form of patches 
> > to the tools/testing directory?  Anything that can reliably trigger rarely 
> > executed code is always useful.
> 
> Perhaps that is a good idea.
> 
> I think should move the directory location in my git-repo
> prototype-kernel[1] to reflect this directory layout, like I do with
> real kernel stuff.  And when we are happy with the quality of the
> scripts we can "move" it to the kernel.  (Like I did with my pktgen
> tests[4], now located in samples/pktgen/).
> 
> A question; where should/could we place the kernel module
> slab_bulk_test04_exhaust_mem[1] that my fail01 script depends on?
> 

I've had the same question because I'd like to add slab and page allocator 
benchmark modules originally developed by Christoph Lameter to the tree.  
Let's add Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
