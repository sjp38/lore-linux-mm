Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 644046B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 13:59:00 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id z11so5435302plo.21
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 10:59:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z85sor1469443pfk.18.2018.02.24.10.58.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Feb 2018 10:58:59 -0800 (PST)
Date: Sat, 24 Feb 2018 10:58:55 -0800
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: tcp_bind_bucket is missing from slabinfo
Message-ID: <20180224105855.5ff93c2f@xeon-e3>
In-Reply-To: <20180224143520.GA22222@bombadil.infradead.org>
References: <20180223225030.2e8ef122@shemminger-XPS-13-9360>
	<20180224143520.GA22222@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

On Sat, 24 Feb 2018 06:35:20 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> On Fri, Feb 23, 2018 at 10:50:30PM -0800, Stephen Hemminger wrote:
> > Somewhere back around 3.17 the kmem cache "tcp_bind_bucket" dropped out
> > of /proc/slabinfo. It turns out the ss command was dumpster diving
> > in slabinfo to determine the number of bound sockets and now it always
> > reports 0.
> > 
> > Not sure why, the cache is still created but it doesn't
> > show in slabinfo. Could it be some part of making slab/slub common code
> > (or network namespaces). The cache is created in tcp_init but not visible.
> > 
> > Any ideas?  
> 
> Try booting with slab_nomerge=1

Yes, thats it. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
