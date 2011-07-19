Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 201FF6B00F1
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 18:37:06 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p6JMb2uj015126
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:37:04 -0700
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by kpbe20.cbf.corp.google.com with ESMTP id p6JMakUL022368
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:37:00 -0700
Received: by iyb26 with SMTP id 26so5450438iyb.23
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:36:56 -0700 (PDT)
Date: Tue, 19 Jul 2011 15:36:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
In-Reply-To: <alpine.LSU.2.00.1106171845480.20321@sister.anvils>
Message-ID: <alpine.LSU.2.00.1107191532130.1541@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140341070.29206@sister.anvils> <20110617163854.49225203.akpm@linux-foundation.org> <20110617170742.282a1bd6.rdunlap@xenotime.net> <20110617171228.4c85fd38.rdunlap@xenotime.net>
 <alpine.LSU.2.00.1106171845480.20321@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: akpm <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Jun 2011, Hugh Dickins wrote:
> On Fri, 17 Jun 2011, Randy Dunlap wrote:
> 
> > > And one Andrew Morton has a userspace radix tree test harness at
> > > http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz
> 
> This should still be as relevant as it was before, but I notice its
> radix_tree.c is almost identical to the source currently in the kernel
> tree, so I ought at the least to keep it in synch.

I was hoping to have dealt with this by now, Randy; but after downloading
an up-to-date urcu, I'm finding what's currently in rtth does not build
with it.  Unlikely to be hard to fix, but means I'll have to defer it a
little while longer.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
