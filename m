Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3EEBB6B0070
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 18:06:37 -0500 (EST)
Received: by ggnq1 with SMTP id q1so394614ggn.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 15:06:34 -0800 (PST)
Date: Wed, 16 Nov 2011 15:06:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slub: fix a code merge error
In-Reply-To: <alpine.LFD.2.02.1111150842590.2347@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1111161503370.16596@chino.kir.corp.google.com>
References: <1320912260.22361.247.camel@sli10-conroe> <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com> <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com> <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
 <alpine.LFD.2.02.1111150842590.2347@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: alex shi <lkml.alex@gmail.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>

On Tue, 15 Nov 2011, Pekka Enberg wrote:

> > SLUB stat attribute was designed for stat accounting only. I checked
> > the total 24 attributes that used now. All of them used in stat() only
> > except the DEACTIVATE_TO_HEAD/TAIL.
> > 
> > And in fact, in the most of using scenarios the DEACTIVATE_TO_TAIL
> > make reader confuse, TO_TAIL is correct but not for DEACTIVATE.
> > 
> > Further more, CL also regretted this after he acked the original
> > patches for this attribute mis-usages. He said "don't think we want
> > this patch any more."
> > http://permalink.gmane.org/gmane.linux.kernel.mm/67653 and want to use
> > a comment instead of this confusing usage.
> > https://lkml.org/lkml/2011/8/29/187
> > 
> > So, as to this regression, from my viewpoint, reverting the
> > DEACTIVATE_TO_TAIL incorrect usage(commit 136333d104) is a better way.
> > :)
> 
> The enum is fine. I don't see any reason to revert the whole commit if
> Shaohua's patch fixes the problem.
> 

It's a slight optimization since "tail" can be set in deactivate_slab() 
and be passed to add_partial() without doing something like !!tail or 
converting it to a boolean as well as using it when calling stat().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
