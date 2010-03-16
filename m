Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B346C6B00B3
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 17:28:47 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o2GLSgxe019583
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:28:43 GMT
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by wpaz21.hot.corp.google.com with ESMTP id o2GLScBr012268
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:28:41 -0700
Received: by pxi2 with SMTP id 2so275646pxi.25
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:28:38 -0700 (PDT)
Date: Tue, 16 Mar 2010 14:26:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND][PATCH 2/2] cpuset: alloc nodemask_t at heap not stack
 (v2)
In-Reply-To: <4B9F759C.8090300@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003161426050.10930@chino.kir.corp.google.com>
References: <4B9F759C.8090300@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Mar 2010, Miao Xie wrote:

> Allocating nodemask_t at heap instead of stack.
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
