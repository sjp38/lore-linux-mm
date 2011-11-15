Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8441D6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 01:45:30 -0500 (EST)
Received: by bke17 with SMTP id 17so913480bke.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 22:45:25 -0800 (PST)
Date: Tue, 15 Nov 2011 08:45:18 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [patch] slub: fix a code merge error
In-Reply-To: <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1111150842590.2347@tux.localdomain>
References: <1320912260.22361.247.camel@sli10-conroe> <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com> <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com> <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alex shi <lkml.alex@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, cl@linux-foundation.org

>> Indeed. Please resend with proper subject and changelog with
>> Christoph's and David's ACKs included.

On Mon, 14 Nov 2011, alex shi wrote:
> SLUB stat attribute was designed for stat accounting only. I checked
> the total 24 attributes that used now. All of them used in stat() only
> except the DEACTIVATE_TO_HEAD/TAIL.
>
> And in fact, in the most of using scenarios the DEACTIVATE_TO_TAIL
> make reader confuse, TO_TAIL is correct but not for DEACTIVATE.
>
> Further more, CL also regretted this after he acked the original
> patches for this attribute mis-usages. He said "don't think we want
> this patch any more."
> http://permalink.gmane.org/gmane.linux.kernel.mm/67653 and want to use
> a comment instead of this confusing usage.
> https://lkml.org/lkml/2011/8/29/187
>
> So, as to this regression, from my viewpoint, reverting the
> DEACTIVATE_TO_TAIL incorrect usage(commit 136333d104) is a better way.
> :)

The enum is fine. I don't see any reason to revert the whole commit if 
Shaohua's patch fixes the problem.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
