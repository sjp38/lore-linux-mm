Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 99C0F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:22:17 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hu19so939790vcb.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 08:22:16 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id e7si458368vch.16.2014.04.08.08.22.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 08:22:15 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id ld13so880541vcb.5
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 08:22:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53440A5D.6050301@zytor.com>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
	<53440A5D.6050301@zytor.com>
Date: Tue, 8 Apr 2014 08:22:15 -0700
Message-ID: <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 8, 2014 at 7:40 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> David, is your patchset going to be pushed in this merge window as expected?

Apparently aiming for 3.16 right now.

> That being said, these bits are precious, and if this ends up being a
> case where "only Xen needs another bit" once again then Xen should
> expect to get kicked to the curb at a moment's notice.

Quite frankly, I don't think it's a Xen-only issue. The code was hard
to figure out even without the Xen issues. For example, nobody ever
explained to me why it

 (a) could be the same as PROTNONE on x86
 (b) could not be the same as PROTNONE in general

I think the best explanation for it so far was from the little voices
in my head that sang "It's a kind of Magic", and that isn't even
remotely the best song by Queen.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
