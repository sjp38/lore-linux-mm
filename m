Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1346B0038
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:01:41 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id lg15so1020821vcb.16
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:01:39 -0700 (PDT)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id fn10si500106vdc.153.2014.04.08.10.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 10:01:39 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id lg15so1020815vcb.16
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:01:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140408164652.GL7292@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
	<53440A5D.6050301@zytor.com>
	<CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
	<20140408164652.GL7292@suse.de>
Date: Tue, 8 Apr 2014 10:01:39 -0700
Message-ID: <CA+55aFwrwYmWFXWpPeg-keKukW0=dwvmUBuN4NKA=JcseiUX3g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 8, 2014 at 9:46 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> If you are ok with leaving _PAGE_NUMA as _PAGE_PROTNONE

NO I AM NOT!

Dammit, this feature is f*cking brain-damaged.

My complaint has been (and continues to be):

 - either it is 100% the same as PROTNONE, in which case thjat
_PAGE_NUMA bit had better go away, and you just use the protnone
helpers!

 - if it's not the same as PROTNONE, then it damn well needs a different bit.

You can't have it both ways. You guys tried. The Xen case shows that
trying to distinguish the two DOES NOT WORK. But even apart from the
Xen case, it was just a confusing hell.

Like Yoda said: "Either they are the same or they are not. There is no 'try'".

So pick one solution. Don't try to pick the mixed-up half-way case
that is a disaster and makes no sense.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
