Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2517E6B00B2
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:36:08 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id y1so5800463lam.6
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:36:07 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id oc6si7766938lbb.25.2014.03.11.10.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 10:36:06 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id s7so5968001lbd.9
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:36:05 -0700 (PDT)
Date: Tue, 11 Mar 2014 21:36:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311173603.GG32390@moon>
References: <20140310214612.3b4de36a.akpm@linux-foundation.org>
 <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
 <20140311134158.GD32390@moon>
 <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
 <20140311171045.GA4693@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311171045.GA4693@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 01:10:45PM -0400, Dave Jones wrote:
>  > 
>  > Dave, iirc trinity can write log file pointing which exactly syscall sequence
>  > was passed, right? Share it too please.
> 
> Hm, I may have been mistaken, and the damage was done by a previous run.
> I went from being able to reproduce it almost instantly to now not being able
> to reproduce it at all.  Will keep trying.

Sasha already gave a link to the syscalls sequence, so no rush.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
