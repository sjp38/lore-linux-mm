Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13D756B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:28:51 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e186so8813037iof.9
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:28:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o73sor4515456ito.129.2018.01.18.09.28.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 09:28:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7B3446FC@ORSMSX110.amr.corp.intel.com>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name> <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com> <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <3908561D78D1C84285E8C5FCA982C28F7B3446FC@ORSMSX110.amr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Jan 2018 09:28:48 -0800
Message-ID: <CA+55aFzviumvZcV4a4ddtLu5T_ibCD_Xia+7W5khY3pMQ--jUA@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "vbabka@suse.cz" <vbabka@suse.cz>, "mhocko@kernel.org" <mhocko@kernel.org>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "hughd@google.com" <hughd@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Thu, Jan 18, 2018 at 9:26 AM, Luck, Tony <tony.luck@intel.com> wrote:
>> Both are real page. But why do you expect pages to be 64-byte alinged?
>> Both are aligned to 64-bit as they suppose to be IIUC.
>
> On a 64-bit kernel sizeof struct page == 64 (after much work by people to
> trim out excess stuff).  So I thought we made sure to align the base address
> of blocks of "struct page" so that every one neatly fits into one cache line.

The bug happens on 32-bit, and a 'struct page' is not 64-byte aligned
there at all.

See my other email about the explanation of why "page1 - page2"
doesn't work when they aren't mutually aligned to the actual size of
the 'struct page'.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
