Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CECBC6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 05:11:02 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz1so3968466pad.35
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 02:11:02 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id u5si7776568pbi.328.2014.03.07.02.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 02:11:01 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id hz1so3970646pad.7
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 02:11:00 -0800 (PST)
Date: Fri, 7 Mar 2014 02:10:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempool: add unlikely and likely hints
In-Reply-To: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.02.1403070210080.31668@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org

On Thu, 6 Mar 2014, Mikulas Patocka wrote:

> This patch adds unlikely and likely hints to the function mempool_free. It
> lays out the code in such a way that the common path is executed
> straighforward and saves a cache line.
> 

What observable performance benefit have you seen with this patch and 
with what architecture?  Could we include some data in the changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
