Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id ED2B16B002D
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 22:02:32 -0500 (EST)
Subject: Re: [patch] slub: fix a code merge error
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
References: <1320912260.22361.247.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
	 <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
	 <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Nov 2011 11:12:04 +0800
Message-ID: <1321240324.22361.272.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alex shi <lkml.alex@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>

On Mon, 2011-11-14 at 09:56 +0800, alex shi wrote:
> >
> > Indeed. Please resend with proper subject and changelog with
> > Christoph's and David's ACKs included.
> 
> Pekka:
> 
> SLUB stat attribute was designed for stat accounting only. I checked
> the total 24 attributes that used now. All of them used in stat() only
> except the DEACTIVATE_TO_HEAD/TAIL.
it's an enum, it can be used in any case if proper used.

> And in fact, in the most of using scenarios the DEACTIVATE_TO_TAIL
> make reader confuse, TO_TAIL is correct but not for DEACTIVATE.
please look at the comments where DEACTIVATE_TO_TAIL is defined.

> Further more, CL also regretted this after he acked the original
> patches for this attribute mis-usages. He said "don't think we want
> this patch any more."
> http://permalink.gmane.org/gmane.linux.kernel.mm/67653 and want to use
> a comment instead of this confusing usage.
> https://lkml.org/lkml/2011/8/29/187
> 
> So, as to this regression, from my viewpoint, reverting the
> DEACTIVATE_TO_TAIL incorrect usage(commit 136333d104) is a better way.
>  :)
using 0/1 is insane and can easily cause problems. Using a name can help
avoid such insane. This is exactly what commit 136333d104 tries to do.
This is a general C programming skill everybody should already know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
