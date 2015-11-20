Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF76B6B0255
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 18:28:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so39672976wmw.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 15:28:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g2si2777655wjw.4.2015.11.20.15.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 15:28:19 -0800 (PST)
Date: Fri, 20 Nov 2015 15:28:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Memory exhaustion testing?
Message-Id: <20151120152817.388f3faf99bf657b9ae5ab30@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1511201522150.10092@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com>
	<alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
	<20151116152440.101ea77d@redhat.com>
	<20151117142120.494947f9@redhat.com>
	<alpine.DEB.2.10.1511191239001.7151@chino.kir.corp.google.com>
	<20151120140916.33ec7896@redhat.com>
	<alpine.DEB.2.10.1511201522150.10092@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Fri, 20 Nov 2015 15:23:09 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Fri, 20 Nov 2015, Jesper Dangaard Brouer wrote:
> 
> > > Any chance you could proffer some of your scripts in the form of patches 
> > > to the tools/testing directory?  Anything that can reliably trigger rarely 
> > > executed code is always useful.
> > 
> > Perhaps that is a good idea.
> > 
> > I think should move the directory location in my git-repo
> > prototype-kernel[1] to reflect this directory layout, like I do with
> > real kernel stuff.  And when we are happy with the quality of the
> > scripts we can "move" it to the kernel.  (Like I did with my pktgen
> > tests[4], now located in samples/pktgen/).
> > 
> > A question; where should/could we place the kernel module
> > slab_bulk_test04_exhaust_mem[1] that my fail01 script depends on?
> > 
> 
> I've had the same question because I'd like to add slab and page allocator 
> benchmark modules originally developed by Christoph Lameter to the tree.  
> Let's add Andrew.

Well, fwiw the current approach is to build the testing module in lib/
(ls -l lib/*test*.c) and to modprobe it from selftests (grep -r
modprobe tools/testing/selftests).

Does that suit?  I guess we could build and install a module from mm/
if that's needed for some reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
