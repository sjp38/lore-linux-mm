Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2666B00E7
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:55:11 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id mz13so1239573bkb.32
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:55:10 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id lu10si3902400bkb.38.2014.02.21.14.55.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 14:55:09 -0800 (PST)
Date: Fri, 21 Feb 2014 23:55:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140221225508.GH22728@two.firstfloor.org>
References: <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213407.GA11048@amt.cnet>
 <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
 <20140221022800.GA30230@amt.cnet>
 <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
 <20140221191055.GD19955@amt.cnet>
 <alpine.DEB.2.02.1402211358030.4682@chino.kir.corp.google.com>
 <20140221223616.GG22728@two.firstfloor.org>
 <alpine.DEB.2.02.1402211440120.20113@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402211440120.20113@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Marcelo Tosatti <mtosatti@redhat.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> But, like I said, I'm not sure we'd ever be able to totally remove it 
> because of backwards compatibility, but the point is that nobody would 
> have to use it anymore as a hack for 1GB.

Again it's a perfectly fine and widely used interface. Any talk of removing
it is wrong.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
