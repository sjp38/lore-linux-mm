Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 37E686B009A
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 09:42:02 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so5480146lbi.8
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:42:01 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id am6si22083490lbc.18.2014.03.11.06.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 06:42:00 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id p9so5705517lbv.10
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:42:00 -0700 (PDT)
Date: Tue, 11 Mar 2014 17:41:58 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311134158.GD32390@moon>
References: <20140305175725.GB16335@redhat.com>
 <20140307002210.GA26603@redhat.com>
 <20140311024906.GA9191@redhat.com>
 <20140310201340.81994295.akpm@linux-foundation.org>
 <20140310214612.3b4de36a.akpm@linux-foundation.org>
 <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
 <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <531F0E39.9020100@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 11, 2014 at 09:23:05AM -0400, Sasha Levin wrote:
> >>
> >>Ok, with move_pages excluded it still oopses.
> >
> >Dave, is it possible to somehow figure out was someone reading pagemap file
> >at moment of the bug triggering?
> 
> We can sprinkle printk()s wherever might be useful, might not be 100% accurate but
> should be close enough to confirm/deny the theory.

After reading some more, I suppose the idea I had is wrong, investigating.
Will ping if I find something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
