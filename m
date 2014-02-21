Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6762C6B00AB
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 15:57:10 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so5108913oah.17
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 12:57:10 -0800 (PST)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id tm2si7916637oeb.42.2014.02.21.12.57.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 12:57:09 -0800 (PST)
Message-ID: <1393016226.3039.44.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 21 Feb 2014 12:57:06 -0800
In-Reply-To: <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2014-02-21 at 10:13 -0800, Linus Torvalds wrote:
> On Thu, Feb 20, 2014 at 9:28 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > From: Davidlohr Bueso <davidlohr@hp.com>
> >
> > This patch is a continuation of efforts trying to optimize find_vma(),
> > avoiding potentially expensive rbtree walks to locate a vma upon faults.
> 
> Ok, so I like this one much better than the previous version.

Btw, one concern I had is regarding seqnum overflows... if such
scenarios should happen we'd end up potentially returning bogus vmas and
getting bus errors and other sorts of issues. So we'd have to flush the
caches, but, do we care? I guess on 32bit systems it could be a bit more
possible to trigger given enough forking.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
