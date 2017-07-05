Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 22C696B040F
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:41:14 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t188so117608oih.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:41:14 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id a62si90579oic.313.2017.07.05.14.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:41:13 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id n2so235928oig.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:41:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705141849.2e0e4721d975277183eb178f@linux-foundation.org>
References: <20170705165602.15005-1-mhocko@kernel.org> <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
 <20170705182849.GA18027@dhcp22.suse.cz> <20170705141849.2e0e4721d975277183eb178f@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jul 2017 14:41:12 -0700
Message-ID: <CA+55aFzqn2448aki-2L1aOdZ+1nsdSc0JMxv-tnqUzdbe8+L+A@mail.gmail.com>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes in
 the stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jul 5, 2017 at 2:18 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 5 Jul 2017 20:28:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>>>
>> Fixes: d4d2d35e6ef9 ("mm: larger stack guard gap, between vmas")
>
> That should be 1be7107fbe18, yes?

Good catch. I assume the d4d2d35e6ef9 is one of the stable backport commits..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
