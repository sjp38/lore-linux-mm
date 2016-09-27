Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9A828027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:16:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so2566379wmc.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 03:16:22 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id uw3si1609588wjb.68.2016.09.27.03.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 03:16:19 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id b130so4331873wmc.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 03:16:18 -0700 (PDT)
MIME-Version: 1.0
From: Shaun Tancheff <shaun@tancheff.com>
Date: Tue, 27 Sep 2016 05:16:15 -0500
Message-ID: <CAJ48U8XgWQZBFuWt2Gk_5JAXz3wONgd15OmBY0M-Urq+_VGe9A@mail.gmail.com>
Subject: BUG Re: mm: vma_merge: fix vm_page_prot SMP race condition against rmap_walk
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Shaun Tancheff <shaun@tancheff.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Shaun Tancheff <shaun.tancheff@seagate.com>

git bisect points at commit  c9634dcf00c9c93b ("mm: vma_merge: fix
vm_page_prot SMP race condition against rmap_walk")

Last lines to console are [transcribed]:

vma ffff8c3d989a7c78 start 00007fe02ed4c000 end 00007fe02ed52000
next ffff8c3d96de0c38 prev ffff8c3d989a6e40 mm ffff8c3d071cbac0
prot 8000000000000025 anon_vma ffff8c3d96fc9b28 vm_ops           (null)
pgoff 7fe02ed4c file           (null) private_data           (null)
flags: 0x8100073(read|write|mayread|maywrite|mayexec|account|softdirty)

Reproducer is an Ubuntu 16.04.1 LTS x86_64 running on a VM (VirtualBox).
Symptom is a solid hang after boot and switch to starting gnome session.

Hang at about 35s.

kdbg traceback is all null entries.

Let me know what additional information I can provide.

Regards,
Shaun Tancheff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
