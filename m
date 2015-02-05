Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 27170828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 06:45:05 -0500 (EST)
Received: by pdjy10 with SMTP id y10so7320594pdj.7
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 03:45:04 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id vx6si5806149pac.141.2015.02.05.03.45.02
        for <linux-mm@kvack.org>;
        Thu, 05 Feb 2015 03:45:04 -0800 (PST)
Date: Thu, 5 Feb 2015 22:45:00 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] gfs2: use __vmalloc GFP_NOFS for fs-related allocations.
Message-ID: <20150205114459.GI12722@dastard>
References: <1422849594-15677-1-git-send-email-green@linuxhacker.ru>
 <20150202053708.GG4251@dastard>
 <E68E8257-1CE5-4833-B751-26478C9818C7@linuxhacker.ru>
 <20150202081115.GI4251@dastard>
 <54CF51C5.5050801@redhat.com>
 <20150203223350.GP6282@dastard>
 <BD2045CE-45AD-4D79-8C8D-C854D112DCC5@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BD2045CE-45AD-4D79-8C8D-C854D112DCC5@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Feb 04, 2015 at 02:13:29AM -0500, Oleg Drokin wrote:
> Hello!
> 
> On Feb 3, 2015, at 5:33 PM, Dave Chinner wrote:
> >> I also wonder if vmalloc is still very slow? That was the case some
> >> time ago when I noticed a problem in directory access times in gfs2,
> >> which made us change to use kmalloc with a vmalloc fallback in the
> >> first place,
> > Another of the "myths" about vmalloc. The speed and scalability of
> > vmap/vmalloc is a long solved problem - Nick Piggin fixed the worst
> > of those problems 5-6 years ago - see the rewrite from 2008 that
> > started with commit db64fe0 ("mm: rewrite vmap layer")....
> 
> This actually might be less true than one would hope. At least somewhat
> recent studies by LLNL (https://jira.hpdd.intel.com/browse/LU-4008)
> show that there's huge contention on vmlist_lock, so if you have vmalloc

vmlist_lock and the list it protected went away in 3.10.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
