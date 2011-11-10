Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C62A6B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 23:50:04 -0500 (EST)
Received: by ywa17 with SMTP id 17so3238254ywa.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 20:50:01 -0800 (PST)
Date: Wed, 9 Nov 2011 20:49:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111092048520.27280@chino.kir.corp.google.com>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com> <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>, Russell King <linux@arm.linux.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>

On Thu, 10 Nov 2011, Nai Xia wrote:

> Did this patch get merged at last, or on this way being merged, or
> just dropped ?
> 

I thought we were waiting to find out if it caused a problem on arm.  
Either Russell should be able to clarify that or a couple months in 
linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
