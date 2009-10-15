Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2D066B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 17:17:41 -0400 (EDT)
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id n9FLHbLm010912
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 14:17:37 -0700
Received: from pxi42 (pxi42.prod.google.com [10.243.27.42])
	by zps18.corp.google.com with ESMTP id n9FLHYic027600
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 14:17:35 -0700
Received: by pxi42 with SMTP id 42so1114122pxi.5
        for <linux-mm@kvack.org>; Thu, 15 Oct 2009 14:17:34 -0700 (PDT)
Date: Thu, 15 Oct 2009 14:17:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
In-Reply-To: <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0910151414570.25796@chino.kir.corp.google.com>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils> <Pine.LNX.4.64.0910150153560.3291@sister.anvils> <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:

> Hmm...maybe I don't understand the benefit of this style of data structure.
> 
> Do we need fine grain chain ? 
> Is  array of "unsigned long" counter is bad ?  (too big?)
> 

I'm wondering if flex_array can be used for this purpose, which can store 
up to 261632 elements of size unsigned long with 4K pages, or whether 
finding the first available bit or weight would be too expensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
