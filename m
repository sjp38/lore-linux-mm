Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 618966B025F
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:58:33 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y20so10915188ita.5
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:58:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n132sor4330433ita.136.2018.01.18.08.58.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 08:58:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4a6681a7-5ed6-ad9c-5d1d-73f1fcc82f3d@linux.intel.com>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name> <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
 <4a6681a7-5ed6-ad9c-5d1d-73f1fcc82f3d@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Jan 2018 08:58:31 -0800
Message-ID: <CA+55aFzN5+S6c=J+nudHfcwidANejGQL9NkX2yF-hr5upM+gag@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Thu, Jan 18, 2018 at 6:38 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 01/18/2018 05:12 AM, Kirill A. Shutemov wrote:
>> -             if (pte_page(*pvmw->pte) - pvmw->page >=
>> -                             hpage_nr_pages(pvmw->page)) {
>
> Is ->pte guaranteed to map a page which is within the same section as
> pvmw->page?  Otherwise, with sparsemem (non-vmemmap), the pointer
> arithmetic won't work.

Lovely.

Finally a reason for this bug that actually seems to make sense.

Thanks guys.

Tetsuo - does Kirill's latest patch fix this for you? The one with

    Subject: [PATCH] mm, page_vma_mapped: Fix pointer arithmetics in check_pte()

in the body of the email? I'm really hoping it does, since this seems
to make sense.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
