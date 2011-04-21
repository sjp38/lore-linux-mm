Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2CD8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:34:11 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p3LLY9M0001242
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:34:09 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe11.cbf.corp.google.com with ESMTP id p3LLY8BS026999
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:34:08 -0700
Received: by pwj9 with SMTP id 9so96720pwj.20
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:34:07 -0700 (PDT)
Date: Thu, 21 Apr 2011 14:34:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303421088.4025.52.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104211431500.20201@chino.kir.corp.google.com>
References: <1303317178.2587.30.camel@mulgrave.site> <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com> <20110421220351.9180.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com> <alpine.DEB.2.00.1104211500170.5741@router.home>
 <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com> <1303421088.4025.52.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 21 Apr 2011, James Bottomley wrote:

> >  - parisc: James has already queued "parisc: set memory ranges in 
> >    N_NORMAL_MEMORY when onlined" for 2.6.39, so all he needs now is 
> >    to merge a hybrid of the Kconfig changes requiring CONFIG_NUMA for 
> >    CONFIG_DISCONTIGMEM from KOSAKI-san and myself which also fix the 
> >    compile issues,
> 
> Not quite: if we go this route, we need to sort out our CPU scheduling
> problem as well ... as I said, I don't think we've got all the necessary
> numa machinery in place yet.
> 

Ok, it seems like there're two options for this release cycle:

 (1) merge the patch that enables CONFIG_NUMA for DISCONTIGMEM but only 
     do so if CONFIG_SLUB is enabled to avoid the build error, or

 (2) disallow CONFIG_SLUB for parisc with DISCONTIGMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
