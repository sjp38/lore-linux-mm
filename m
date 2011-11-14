Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBA76B002D
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 20:56:54 -0500 (EST)
Received: by vws16 with SMTP id 16so6343824vws.14
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 17:56:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
References: <1320912260.22361.247.camel@sli10-conroe>
	<alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
	<CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
Date: Mon, 14 Nov 2011 09:56:52 +0800
Message-ID: <CAGjg+kHstQGLvT+=K9v_s=hLDd0974JHR0N5EVsTbkYk2=s1vQ@mail.gmail.com>
Subject: Re: [patch] slub: fix a code merge error
From: alex shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, cl@linux-foundation.org

>
> Indeed. Please resend with proper subject and changelog with
> Christoph's and David's ACKs included.

Pekka:

SLUB stat attribute was designed for stat accounting only. I checked
the total 24 attributes that used now. All of them used in stat() only
except the DEACTIVATE_TO_HEAD/TAIL.

And in fact, in the most of using scenarios the DEACTIVATE_TO_TAIL
make reader confuse, TO_TAIL is correct but not for DEACTIVATE.

Further more, CL also regretted this after he acked the original
patches for this attribute mis-usages. He said "don't think we want
this patch any more."
http://permalink.gmane.org/gmane.linux.kernel.mm/67653 and want to use
a comment instead of this confusing usage.
https://lkml.org/lkml/2011/8/29/187

So, as to this regression, from my viewpoint, reverting the
DEACTIVATE_TO_TAIL incorrect usage(commit 136333d104) is a better way.
 :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
