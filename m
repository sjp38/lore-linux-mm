Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFA36B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 16:08:37 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so99933pab.30
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 13:08:36 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ze10si158087pac.23.2014.07.10.13.08.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 13:08:36 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so104514pad.7
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 13:08:35 -0700 (PDT)
Date: Thu, 10 Jul 2014 13:06:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
In-Reply-To: <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407101301230.20929@eggly.anvils>
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com>
 <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com> <53BECBA4.3010508@oracle.com> <alpine.LSU.2.11.1407101033280.18934@eggly.anvils> <53BED7F6.4090502@oracle.com> <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 10 Jul 2014, Hugh Dickins wrote:
> 
> I'll pore over the new log.  It does help to know that its base kernel
> is more stable: thanks so much.  But whether I can work out any more...

Actually, today's log is not much use to me: for a tenth of a second
it just shows "NNN printk messages dropped" instead of task traces.
Do you have a better one?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
