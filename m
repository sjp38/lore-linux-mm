Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 236AC6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 10:25:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 12E3182C540
	for <linux-mm@kvack.org>; Fri,  8 May 2009 10:38:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DI5mXzxYT7sG for <linux-mm@kvack.org>;
	Fri,  8 May 2009 10:38:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 362DE82C54D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 10:37:47 -0400 (EDT)
Date: Fri, 8 May 2009 10:25:26 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <20090508183427.f313770f.minchan.kim@barrios-desktop>
Message-ID: <alpine.DEB.1.10.0905081022490.23875@qirst.com>
References: <20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>
 <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090508030209.GA8892@localhost> <20090508163042.ba4ef116.minchan.kim@barrios-desktop> <20090508080921.GA25411@localhost> <20090508183427.f313770f.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 8 May 2009, Minchan Kim wrote:

> > > Why did you said that "The page_referenced() path will only cover the ""_text_"" section" ?
> > > Could you elaborate please ?
> >
> > I was under the wild assumption that only the _text_ section will be
> > PROT_EXEC mapped.  No?
>
> Yes. I support your idea.

Why do PROT_EXEC mapped segments deserve special treatment? What about the
other memory segments of the process? Essentials like stack, heap and
data segments of the libraries?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
