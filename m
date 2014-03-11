Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 926926B00AE
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:11:00 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id f11so8701058qae.3
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:11:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d8si7327123qao.144.2014.03.11.10.10.59
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 10:11:00 -0700 (PDT)
Date: Tue, 11 Mar 2014 13:10:45 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311171045.GA4693@redhat.com>
References: <20140310201340.81994295.akpm@linux-foundation.org>
 <20140310214612.3b4de36a.akpm@linux-foundation.org>
 <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
 <20140311134158.GD32390@moon>
 <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311143750.GE32390@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 06:37:50PM +0400, Cyrill Gorcunov wrote:
 
 > >  > After reading some more, I suppose the idea I had is wrong, investigating.
 > >  > Will ping if I find something.
 > > 
 > > I can rule it out anyway, I can reproduce this by telling trinity to do nothing
 > > other than mmap()'s.   I'll try and narrow down the exact parameters.
 > 
 > Dave, iirc trinity can write log file pointing which exactly syscall sequence
 > was passed, right? Share it too please.

Hm, I may have been mistaken, and the damage was done by a previous run.
I went from being able to reproduce it almost instantly to now not being able
to reproduce it at all.  Will keep trying.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
