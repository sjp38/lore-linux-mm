Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 898C76B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:51:57 -0500 (EST)
Received: by mail-gg0-f174.google.com with SMTP id g10so2515146gga.19
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:51:57 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id k66si5028942yhc.186.2014.01.21.01.51.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 01:51:56 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f73so1787222yha.31
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:51:56 -0800 (PST)
Date: Tue, 21 Jan 2014 01:51:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V5 1/3] mm/nobootmem: Fix unused variable
In-Reply-To: <20140121075738.771d29b3@lilie>
Message-ID: <alpine.DEB.2.02.1401210150220.29987@chino.kir.corp.google.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com> <1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com> <alpine.DEB.2.02.1401202214540.21729@chino.kir.corp.google.com> <20140121075738.771d29b3@lilie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 21 Jan 2014, Philipp Hachtmann wrote:

> > Not sure why you don't just do a one line patch:
> > 
> > -	phys_addr_t size;
> > +	phys_addr_t size __maybe_unused;
> > to fix it.
> 
> Just because I did not know that __maybe_unused thing.
> 

-	phys_addr_t size;
+	phys_addr_t size = 0;

would have done the same thing.

The compiler generated code isn't going to change with either of these, so 
we're only talking about how the source code is structured.  If you and 
Andrew believe that adding block scope to something so trivial then that's 
your taste.  Looks ugly to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
