Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8922D6B004D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 17:01:02 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o1MM0w3G008600
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:00:58 -0800
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz9.hot.corp.google.com with ESMTP id o1MLxeDq007735
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:00:57 -0800
Received: by pwi9 with SMTP id 9so2910151pwi.24
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:00:57 -0800 (PST)
Date: Mon, 22 Feb 2010 14:00:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <20100222121222.GV9738@laptop>
Message-ID: <alpine.DEB.2.00.1002221400060.23881@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <20100222121222.GV9738@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Feb 2010, Nick Piggin wrote:

> If you have a concurrent reader without any synchronisation, then what
> stops it from loading a word of the mask before stores to add the new
> nodes and then loading another word of the mask after the stores to
> remove the old nodes? (which can give an empty mask).
> 

Currently nothing, so we'll need a variant for configurations where the 
size of nodemask_t is larger than we can atomically store.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
