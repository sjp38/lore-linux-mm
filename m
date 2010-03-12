Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1C36B012B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 04:46:54 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id o2C9knKA023422
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:46:49 GMT
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by spaceape7.eur.corp.google.com with ESMTP id o2C9klfZ029845
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 01:46:48 -0800
Received: by pxi33 with SMTP id 33so396292pxi.12
        for <linux-mm@kvack.org>; Fri, 12 Mar 2010 01:46:47 -0800 (PST)
Date: Fri, 12 Mar 2010 01:46:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mmotm 1/2] cpuset: fix the problem that cpuset_mem_spread_node()
 returns an offline node - fix
In-Reply-To: <4B99E62C.1020500@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003120145440.22682@chino.kir.corp.google.com>
References: <4B99E62C.1020500@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010, Miao Xie wrote:

> Remove unnecessary smp_wmb().
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Andrew can easily fold this into its parent patch now before pushing to 
Linus, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
