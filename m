Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 261256B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:47:16 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id vb8so9768895obc.11
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:47:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id sz9si67768466obc.33.2014.07.10.05.47.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:47:15 -0700 (PDT)
Message-ID: <53BE8B1B.3000808@oracle.com>
Date: Thu, 10 Jul 2014 08:46:19 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com> <alpine.LSU.2.11.1407092358090.18131@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407092358090.18131@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/10/2014 03:37 AM, Hugh Dickins wrote:
> I do think that the most useful thing you could do at the moment,
> is to switch away from running trinity on -next temporarily, and
> run it instead on Linus's current git or on 3.16-rc4, but with
> f00cdc6df7d7 reverted and my "take 2" inserted in its place.
> 
> That tree would also include Heiko's seq_buf_alloc() patch, which
> trinity on -next has cast similar doubt upon: at present, we do
> not know if Heiko's patch and my patch are bad in themselves,
> or exposing other bugs in 3.16-rc, or exposing bugs in -next.

Funny enough, Linus's tree doesn't even boot properly here. It's
going to take longer than I expected...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
