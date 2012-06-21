Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 86D776B00F1
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 15:22:56 -0400 (EDT)
Date: Thu, 21 Jun 2012 21:22:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
Message-ID: <20120621192253.GD15472@liondog.tnic>
Reply-To: Borislav Petkov <borislav.petkov@amd.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
 <1340057126-31143-5-git-send-email-riel@redhat.com>
 <20120619162747.fa31c86a.akpm@linux-foundation.org>
 <4FE35F4E.3080002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FE35F4E.3080002@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Thu, Jun 21, 2012 at 01:52:14PM -0400, Rik van Riel wrote:
> >Some performance tests on the result would be interesting.  iirc, we've
> >often had trouble demonstrating much or any benefit from coloring.
> 
> On AMD Bulldozer, I do not know what the benefits are.

I have arranged for running a bunch of benchmarks with and without your
patchset on Bulldozer, basically everything you can get in autotest.

Also, if you have any other microbenchmarks or tests your want run, ping
me.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
