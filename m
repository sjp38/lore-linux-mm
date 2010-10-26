Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 10F018D0001
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 07:17:46 -0400 (EDT)
Date: Tue, 26 Oct 2010 07:14:29 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <862326461.384731288091669063.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.LSU.2.00.1010260045120.2939@sister.anvils>
Subject: Re: understand KSM
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > There are 3 programs (A, B ,C) to allocate 128M memory each using
> KSM.
> > 
> > A has memory content equal 'c'.
> > B has memory content equal 'a'.
> > C has memory content equal 'a'.
> > 
> > Then (using the latest mmotm tree),
> > pages_shared = 2
> > pages_sharing = 98292
> > pages_unshared = 0
> 
> So, after KSM has done its best, it all reduces to 1 page full of
> 'a's and another 1 page full of 'c's.
I would expect pages_sharing to be 98302 (128 * 256 - 2), but this one looks unstable. Increased pages_to_scan to 2 * 98304 did not help either.

Thanks for the other suggestions! After modified the test accordingly, it looks like work as expected.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
