Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 47FAF6B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 20:01:41 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p9D01Xnk023366
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 17:01:33 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by wpaz5.hot.corp.google.com with ESMTP id p9D001Hs001622
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 17:01:32 -0700
Received: by pzd13 with SMTP id 13so1715738pzd.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 17:01:23 -0700 (PDT)
Date: Wed, 12 Oct 2011 17:01:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, hannes@cmpxchg.org

On Wed, 12 Oct 2011, Satoru Moriya wrote:

> > I think the point was that extra_free_kbytes needs to be tuned to 
> > cover at least the amount of memory of the largest allocation burst
> 
> Right. In enterprise area, we strictly test the system we build
> again and again before we release it. In that situation, we can
> set extra_free_kbytes appropriately based on system's requirements
> and/or specifications etc.
> 

You would also need to guarantee that min_free_kbytes isn't subsequently 
changed because that would change the value that extra_free_kbytes would 
need to preserve the same exclusive access to memory that the rt threads 
would have without increasing it.

> I understand what you concern. But in some area such as banking,
> stock exchange, train/power/plant control sysemts etc this kind
> of tunable is welcomed because they can tune their systems at
> their own risk.
> 

You haven't tried the patch that increases the priority of kswapd when 
such a latency sensitive thread triggers background reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
