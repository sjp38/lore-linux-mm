Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 70F1E6B0254
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:15:18 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so93388289pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:15:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id a16si21738657pbu.151.2015.10.22.08.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:15:17 -0700 (PDT)
Date: Thu, 22 Oct 2015 17:15:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022151509.GO3604@twins.programming.kicks-ass.net>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
 <20151022121056.GB7520@twins.programming.kicks-ass.net>
 <20151022132015.GF19147@redhat.com>
 <20151022133824.GR17308@twins.programming.kicks-ass.net>
 <20151022141831.GA1331@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022141831.GA1331@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, Oct 22, 2015 at 04:18:31PM +0200, Andrea Arcangeli wrote:

> The risk of memory corruption is still zero no matter what happens
> here, in the extremely rare case the app will get a SIGBUS or a

That might still upset people, SIGBUS isn't something an app can really
recover from.

> I'm not exactly sure why we allow VM_FAULT_RETRY only once currently
> so I'm tempted to drop FAULT_FLAG_TRIED entirely.

I think to ensure we make forward progress.

> I've no real preference on how to tweak the page fault code to be able
> to return VM_FAULT_RETRY indefinitely and I would aim for the smallest
> change possible, so if you've suggestions now it's good time.

Indefinitely is such a long time, we should try and finish
computation before the computer dies etc. :-)

Yes, yes.. I know, extremely unlikely etc. Still guarantees are good.


In any case, I'm not really too bothered how you fix it, just figured
I'd let you know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
