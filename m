Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4196B025F
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 18:34:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so764953wmp.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 15:34:32 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id d142si2252891lfb.59.2016.07.20.15.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 15:34:30 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l89so4365352lfi.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 15:34:30 -0700 (PDT)
Date: Thu, 21 Jul 2016 01:34:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mmotm-2016-07-18-16-40] page allocation failure: order:2,
 mode:0x2000000(GFP_NOWAIT)
Message-ID: <20160720223427.GA22911@node.shutemov.name>
References: <20160720114417.GA19146@node.shutemov.name>
 <20160720115323.GI11249@dhcp22.suse.cz>
 <9c2c9249-af41-56c2-7169-1465e0c07edc@suse.cz>
 <20160720151905.GB19146@node.shutemov.name>
 <e9ffdc50-b085-c96c-5da7-7358967f421c@suse.cz>
 <CAG_fn=UP0169b+cTxVBhqPUfOurQNxAKne0pYSPy3a1uFvTp-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=UP0169b+cTxVBhqPUfOurQNxAKne0pYSPy3a1uFvTp-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, David Rientjes <rientjes@google.com>, mgorman@techsingularity.net

On Wed, Jul 20, 2016 at 08:12:13PM +0200, Alexander Potapenko wrote:
> >>>>> It's easy to reproduce in my setup: virtual machine with some amount of
> >>>>> swap space and try allocate about the size of RAM in userspace (I used
> >>>>> usemem[1] for that).
>
> Am I understanding right that you're seeing allocation failures from
> the stack depot? How often do they happen? Are they reported under
> heavy load, or just when you boot the kernel?

As I described, it happens under memory pressure.

> Allocating with __GFP_NOWARN will help here, but I think we'd better
> figure out what's gone wrong.
> I've sent https://lkml.org/lkml/2016/7/14/566, which should reduce the
> stack depot's memory consumption, for review - can you see if the bug
> is still reproducible with that?

I was not able to trigger the failure with the same test case.
Tested with v2 of the patch.

(Links to http://lkml.kernel.org/ or other archive with message-id in url
is prefered. lkml.org is garbage)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
