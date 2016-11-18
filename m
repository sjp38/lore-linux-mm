Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2E8B6B03F2
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:52:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so11439703wme.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:52:42 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id m1si7043049wjt.59.2016.11.18.02.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 02:52:41 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m203so4854319wma.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:52:41 -0800 (PST)
Date: Fri, 18 Nov 2016 13:52:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
Message-ID: <20161118105239.GD9430@node>
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Fri, Nov 18, 2016 at 11:19:30AM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've got the following BUG while running syzkaller on
> a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (4.9-rc5). Unfortunately it's
> not reproducible.

I don't think there's enough info to track it down :(

Let me know if you will see this again.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
