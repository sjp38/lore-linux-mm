Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF2A6B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 16:21:19 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p9CKLGXi000740
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:21:16 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by hpaq3.eem.corp.google.com with ESMTP id p9CK8ZJ9001156
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:21:14 -0700
Received: by pzk33 with SMTP id 33so1197604pzk.8
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:21:09 -0700 (PDT)
Date: Wed, 12 Oct 2011 13:21:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <4E959292.9060301@redhat.com>
Message-ID: <alpine.DEB.2.00.1110121316590.7646@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com>
 <alpine.DEB.2.00.1110111343070.29761@chino.kir.corp.google.com> <4E959292.9060301@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 12 Oct 2011, Rik van Riel wrote:

> How would this scheme work?
> 

I suggested a patch from BFS that would raise kswapd to the same priority 
of the task that triggered it (not completely up to rt, but the highest 
possible in that case) and I'm waiting to hear if that helps for Satoru's 
test case before looking at alternatives.  We could also extend the patch 
to raise the priority of an already running kswapd if a higher priority 
task calls into the page allocator's slowpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
