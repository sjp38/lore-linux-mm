Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EFEF96B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:35:55 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so38523669pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:35:55 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id h11si14855275pfd.42.2016.02.25.13.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 13:35:55 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id ho8so39675542pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:35:55 -0800 (PST)
Date: Thu, 25 Feb 2016 13:35:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <alpine.LSU.2.11.1602242136270.6876@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1602251322130.8063@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <877fhttmr1.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1602242136270.6876@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, 24 Feb 2016, Hugh Dickins wrote:
> On Thu, 25 Feb 2016, Aneesh Kumar K.V wrote:
> > 
> > Can you test the impact of the merge listed below ?(ie, revert the merge and see if
> > we can reproduce and also verify with merge applied). This will give us a
> > set of commits to look closer. We had quiet a lot of page table
> > related changes going in this merge window. 
> > 
> > f689b742f217b2ffe7 ("Pull powerpc updates from Michael Ellerman:")
> > 
> > That is the merge commit that added _PAGE_PTE. 
> 
> Another experiment running on it at the moment, I'd like to give that
> a few more hours, and then will try the revert you suggest.  But does
> that merge revert cleanly, did you try?  I'm afraid of interactions,
> whether obvious or subtle, with the THP refcounting rework.  Oh, since
> I don't have THP configured on, maybe I can ignore any issues from that.

That revert worked painlessly, only a very few and simple conflicts,
I ran that under load for 12 hours, no problem seen.

I've now checked out an f689b742 tree and started on that, just to
confirm that it fails fairly quickly I hope; and will then proceed
to git bisect, giving that as bad and 37cea93b as good.

Given the uncertainty of whether 12 hours is really long enough to be
sure, and perhaps difficulties along the way, I don't rate my chances
of a reliable bisection higher than 60%, but we'll see.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
