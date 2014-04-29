Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 214756B0036
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 06:00:05 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id rp18so2445726iec.4
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 03:00:04 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id nz8si15220406icb.33.2014.04.29.03.00.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 03:00:04 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 20:00:00 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3E9E82BB0052
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:59:58 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T9xhcP10617158
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:59:43 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T9xvg0030014
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:59:57 +1000
Message-ID: <535F77E8.2040000@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 15:29:04 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <alpine.LSU.2.11.1404281500180.2861@eggly.anvils> <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net> <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com>
In-Reply-To: <CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 04/29/2014 03:55 AM, Linus Torvalds wrote:
> On Mon, Apr 28, 2014 at 3:14 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>
>> I think that returning some stale/bogus vma is causing those segfaults
>> in udev. It shouldn't occur in a normal scenario. What puzzles me is
>> that it's not always reproducible. This makes me wonder what else is
>> going on...
> 
> I've replaced the BUG_ON() with a WARN_ON_ONCE(), and made it be
> unconditional (so you don't have to trigger the range check).
> 
> That might make it show up earlier and easier (and hopefully closer to
> the place that causes it). Maybe that makes it easier for Srivatsa to
> reproduce this. It doesn't make *my* machine do anything different,
> though.
> 
> Srivatsa? It's in current -git.
> 

I tried this, but still nothing so far. I rebooted 10-20 times, and also
tried multiple runs of multi-threaded ebizzy and kernel compilations,
but none of this hit the warning.

Is there anything more specific I can run to increase the chances of
hitting this? I guess a test-case might be too much to ask since I'm
the first one hitting this, but if anybody has suggestions of scenarios
which have a higher likelihood of hitting this (like running multi-
threaded workloads or whatever), I could probably give it a try as well.

Thank you!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
