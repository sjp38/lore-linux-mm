Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 213A06B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 18:31:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so12755662dak.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 15:31:48 -0700 (PDT)
Date: Tue, 22 May 2012 15:31:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205221216050.17721@router.home>
Message-ID: <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com> <alpine.DEB.2.00.1205220855470.17600@router.home> <4FBBAE95.6080608@parallels.com>
 <alpine.DEB.2.00.1205221216050.17721@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 22 May 2012, Christoph Lameter wrote:

> > I think that's precisely David's point: that we might want to destroy them
> > eventually.
> 
> Cannot imagine why.
> 

We can't predict how slab will be extended in the future and this affects 
anything created before g_cpucache_cpu <= EARLY.  This would introduce the 
first problem with destroying such caches and is unnecessary if a 
workaround exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
