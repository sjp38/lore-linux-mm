Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD676B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 16:13:27 -0500 (EST)
Message-ID: <1320959579.21206.24.camel@pasglop>
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 11 Nov 2011 08:12:59 +1100
In-Reply-To: <4EBC085D.3060107@jp.fujitsu.com>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
	 <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
	 <4EBC085D.3060107@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: nai.xia@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lethal@linux-sh.org, linux@arm.linux.org.uk

On Thu, 2011-11-10 at 12:22 -0500, KOSAKI Motohiro wrote:
> On 11/9/2011 11:09 PM, Nai Xia wrote:
> > Hi all,
> > 
> > Did this patch get merged at last, or on this way being merged, or
> > just dropped ?
> 
> Dropped.
> Linus said he dislike 64bit enhancement.

Do you have a pointer ? (And a rationale)

I still want to put some arch flags in there at some point...

Cheers,
Ben.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
