Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA2E6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 00:00:58 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o9R40u57027776
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 21:00:56 -0700
Received: from yxd5 (yxd5.prod.google.com [10.190.1.197])
	by hpaq1.eem.corp.google.com with ESMTP id o9R40sex031379
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 21:00:54 -0700
Received: by yxd5 with SMTP id 5so103446yxd.32
        for <linux-mm@kvack.org>; Tue, 26 Oct 2010 21:00:54 -0700 (PDT)
Date: Tue, 26 Oct 2010 21:00:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: understand KSM
In-Reply-To: <862326461.384731288091669063.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.LSU.2.00.1010262050140.6304@sister.anvils>
References: <862326461.384731288091669063.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Oct 2010, CAI Qian wrote:
> 
> > > There are 3 programs (A, B ,C) to allocate 128M memory each using
> > KSM.
> > > 
> > > A has memory content equal 'c'.
> > > B has memory content equal 'a'.
> > > C has memory content equal 'a'.
> > > 
> > > Then (using the latest mmotm tree),
> > > pages_shared = 2
> > > pages_sharing = 98292
> > > pages_unshared = 0
> > 
> > So, after KSM has done its best, it all reduces to 1 page full of
> > 'a's and another 1 page full of 'c's.
> I would expect pages_sharing to be 98302 (128 * 256 - 2), but this one looks unstable. Increased pages_to_scan to 2 * 98304 did not help either.

Since your 1MB malloc'ed buffers may not fall on page boundaries,
and there might occasionally be other malloc'ed areas interspersed
amongst them, I'm not surprised that pages_sharing falls a little
short of 98302.  But I am surprised that pages_unshared does not
make up the difference; probably pages_volatile does, but I don't
see why some should remain volatile indefinitely.

> 
> Thanks for the other suggestions! After modified the test accordingly, it looks like work as expected.

Oh good, that's a relief.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
