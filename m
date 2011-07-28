Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C37386B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 18:23:09 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p6SMN6uK030762
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 15:23:06 -0700
Received: from yxj20 (yxj20.prod.google.com [10.190.3.84])
	by wpaz33.hot.corp.google.com with ESMTP id p6SMMTox006865
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 15:23:04 -0700
Received: by yxj20 with SMTP id 20so2785074yxj.22
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 15:23:00 -0700 (PDT)
Date: Thu, 28 Jul 2011 15:22:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] SLAB changes for v3.1-rc0
In-Reply-To: <CAOJsxLHniS9Hx+ep_i2qbE_Oo6PnkNCK5dNARW5egg9Bso4Ovg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1107281514080.29344@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107221108190.2996@tiger> <CAOJsxLHniS9Hx+ep_i2qbE_Oo6PnkNCK5dNARW5egg9Bso4Ovg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 28 Jul 2011, Pekka Enberg wrote:

> Christoph, your debugging fix has been in linux-next for few days now
> and no problem have been reported. I'm considering sending the series
> to Linus. What do you think?
> 

I ran slub/lockless through some stress testing and it seems to be quite 
stable on my testing cluster.  There is about a 2.3% performance 
improvement with the lockless slowpath on the netperf benchmark with 
various thread counts on my 16-core 64GB Opterons, so I'd recommend it to 
be merged into 3.1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
