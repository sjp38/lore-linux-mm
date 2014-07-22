Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E09926B0038
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:23:36 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so463591pad.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:23:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cd4si450877pad.239.2014.07.22.16.23.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 16:23:35 -0700 (PDT)
Message-ID: <53CEF197.9040600@oracle.com>
Date: Tue, 22 Jul 2014 19:19:51 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils> <53CDD961.1080006@oracle.com> <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/22/2014 04:07 AM, Hugh Dickins wrote:
> But there is one easy change which might do it: please would you try
> changing the TASK_KILLABLE a few lines above to TASK_UNINTERRUPTIBLE.

That seems to have done the trick, everything works fine.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
