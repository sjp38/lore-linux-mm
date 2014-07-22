Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3116A6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:59:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so474383pdj.22
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:59:49 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ot7si542268pbc.164.2014.07.22.16.59.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 16:59:48 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so506734pab.40
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:59:47 -0700 (PDT)
Date: Tue, 22 Jul 2014 16:58:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
In-Reply-To: <53CEF197.9040600@oracle.com>
Message-ID: <alpine.LSU.2.11.1407221657150.32060@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils> <53CDD961.1080006@oracle.com> <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
 <53CEF197.9040600@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 22 Jul 2014, Sasha Levin wrote:
> On 07/22/2014 04:07 AM, Hugh Dickins wrote:
> > But there is one easy change which might do it: please would you try
> > changing the TASK_KILLABLE a few lines above to TASK_UNINTERRUPTIBLE.
> 
> That seems to have done the trick, everything works fine.

Super, thank you Sasha: patch to Andrew follows.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
