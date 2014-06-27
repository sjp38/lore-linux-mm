Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D31A6B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 10:53:30 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so4630255pbb.25
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 07:53:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id hn2si14169417pbc.256.2014.06.27.07.53.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 07:53:29 -0700 (PDT)
Message-ID: <53AD84CE.20806@oracle.com>
Date: Fri, 27 Jun 2014 10:50:54 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz> <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53AC383F.3010007@oracle.com> <alpine.LSU.2.11.1406262236370.27670@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406262236370.27670@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 06/27/2014 01:59 AM, Hugh Dickins wrote:
>> > First, this:
>> > 
>> > [  681.267487] BUG: unable to handle kernel paging request at ffffea0003480048
>> > [  681.268621] IP: zap_pte_range (mm/memory.c:1132)
> Weird, I don't think we've seen anything like that before, have we?
> I'm pretty sure it's not a consequence of my "index = min(index, end)",
> but what it portends I don't know.  Please confirm mm/memory.c:1132 -
> that's the "if (PageAnon(page))" line, isn't it?  Which indeed matches
> the code below.  So accessing page->mapping is causing an oops...

Right, that's the correct line.

At this point I'm pretty sure that it's somehow related to that one line
patch since it reproduced fairly quickly after applying it, and when I
removed it I didn't see it happening again during the overnight fuzzing.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
