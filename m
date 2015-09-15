Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6C09D6B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 15:01:47 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so42323081wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:01:46 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id p1si784060wiz.31.2015.09.15.12.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 12:01:46 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so40636120wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:01:46 -0700 (PDT)
Date: Tue, 15 Sep 2015 22:01:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150915190143.GA18670@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
 <55EC9221.4040603@oracle.com>
 <20150907114048.GA5016@node.dhcp.inet.fi>
 <55F0D5B2.2090205@oracle.com>
 <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
 <20150911103959.GA7976@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
 <55F8572D.8010409@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55F8572D.8010409@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrey Konovalov <andreyknvl@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, Sep 15, 2015 at 01:36:45PM -0400, Sasha Levin wrote:
> On 09/11/2015 09:27 PM, Hugh Dickins wrote:
> > I'm inclined to echo Vlastimil's comment from earlier in the thread:
> > sounds like an overkill, unless we find something more serious than this.
> 
> I've modified my tests to stress the exit path of processes with many vmas,

Could you share the test?

> and hit the following NULL ptr deref (not sure if it's related to the original issue):
> 
> [1181047.935563] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
> [1181047.937223] Modules linked in:
> [1181047.937772] CPU: 4 PID: 21912 Comm: trinity-c341 Not tainted 4.3.0-rc1-next-20150914-sasha-00043-geddd763-dirty #2554
> [1181047.939387] task: ffff8804195c8000 ti: ffff880433f00000 task.ti: ffff880433f00000
> [1181047.940533] RIP: unmap_vmas (mm/memory.c:1337)

Is it "struct mm_struct *mm = vma->vm_mm;"?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
