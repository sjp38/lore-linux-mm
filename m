Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE416B0035
	for <linux-mm@kvack.org>; Sat, 31 May 2014 17:18:13 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so2900702pbb.31
        for <linux-mm@kvack.org>; Sat, 31 May 2014 14:18:12 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id bv3si10949550pad.79.2014.05.31.14.18.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 May 2014 14:18:12 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so2116160pdb.17
        for <linux-mm@kvack.org>; Sat, 31 May 2014 14:18:11 -0700 (PDT)
Date: Sat, 31 May 2014 14:16:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: sleeping function warning from __put_anon_vma
In-Reply-To: <538A43E0.5070706@suse.cz>
Message-ID: <alpine.LSU.2.11.1405311411420.1125@eggly.anvils>
References: <20140530000944.GA29942@redhat.com> <alpine.LSU.2.11.1405311321340.10272@eggly.anvils> <538A43E0.5070706@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dave Jones <davej@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 31 May 2014, Vlastimil Babka wrote:
> On 05/31/2014 10:33 PM, Hugh Dickins wrote:
> > On Thu, 29 May 2014, Dave Jones wrote:
> > 
> >> BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:47
> >> in_atomic(): 0, irqs_disabled(): 0, pid: 5787, name: trinity-c27
> >> Preemption disabled at:[<ffffffff990acc7e>] vtime_account_system+0x1e/0x50
> 
> Just wondering, since I'm not familiar with this kind of bug, is the line above
> bogus or what does it mean? I don't see how the stack trace or the fix patch is
> related to vtime_account_system?

I know no more about it than you do, never noticed such a message before,
and clearly not helpful here.  I expect it's like those "last sysfs file"
messages, occasionally useful but mostly noise.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
