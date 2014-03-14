Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1F36B0072
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:27:18 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id s7so1739984lbd.9
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 05:27:17 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id y10si2974201lad.71.2014.03.14.05.27.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 05:27:16 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so1705476lbi.36
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 05:27:15 -0700 (PDT)
Date: Fri, 14 Mar 2014 16:27:14 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140314122714.GR13448@moon>
References: <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
 <20140311134158.GD32390@moon>
 <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
 <20140311171045.GA4693@redhat.com>
 <20140311173603.GG32390@moon>
 <20140311173917.GB4693@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311173917.GB4693@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 01:39:17PM -0400, Dave Jones wrote:
>  > 
>  > Sasha already gave a link to the syscalls sequence, so no rush.
> 
> It'd be nice to get a more concise reproducer, his list had a little of everything in there.

Dave, could you please send me your config privately so I would try to reproduce
the issue locally maybe it shed some light on the problem.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
