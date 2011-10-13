Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0142F6B0182
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 18:03:10 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p9DM34Fu005716
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:03:04 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz17.hot.corp.google.com with ESMTP id p9DLvT9H009384
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:03:03 -0700
Received: by pzk33 with SMTP id 33so5119813pzk.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 15:02:58 -0700 (PDT)
Date: Thu, 13 Oct 2011 15:02:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <4E97541F.9050805@redhat.com>
Message-ID: <alpine.DEB.2.00.1110131501490.24853@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110111612120.5236@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516D459@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110131337580.24853@chino.kir.corp.google.com>
 <4E97541F.9050805@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 13 Oct 2011, Rik van Riel wrote:

> Userspace cannot be responsible, for the simple reason that
> the allocations might be done in the kernel.
> 
> Think about an mlocked realtime program handling network
> packets. Memory is allocated when packets come in, and when
> the program calls sys_send(), which causes packets to get
> sent.
> 
> I don't see how we can make userspace responsible for
> kernel-side allocations.
> 

All of this is what Minchan was proposing by allowing a mempool of kernel 
memory to be preallocated and managed by the memory controller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
