Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 560746B005D
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 15:51:40 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n7LJpirC005312
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:51:45 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz1.hot.corp.google.com with ESMTP id n7LJpeRP010812
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:51:42 -0700
Received: by pxi9 with SMTP id 9so1779078pxi.14
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:51:40 -0700 (PDT)
Date: Fri, 21 Aug 2009 12:51:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: move oom_killer_enable()/oom_killer_disable to
 where they belong
In-Reply-To: <20090821191925.GA5367@x200.localdomain>
Message-ID: <alpine.DEB.2.00.0908211250350.28575@chino.kir.corp.google.com>
References: <20090821191925.GA5367@x200.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Aug 2009, Alexey Dobriyan wrote:

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Although I never liked the oom_killer_{enable,disable}() solution in doing 
swsusp, it's definitely defined in the wrong place.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
