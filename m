Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id BF9CA6B005A
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 20:18:30 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so2716162veb.36
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 17:18:29 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id gs7si411241vdc.146.2014.04.09.17.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 17:12:28 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so2748716vcb.18
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 17:12:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5345D912.7000606@zytor.com>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
	<53440A5D.6050301@zytor.com>
	<CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
	<20140408164652.GL7292@suse.de>
	<20140408173031.GS10526@twins.programming.kicks-ass.net>
	<20140409062103.GA7294@gmail.com>
	<5345D912.7000606@zytor.com>
Date: Wed, 9 Apr 2014 17:12:24 -0700
Message-ID: <CA+55aFwMVjsYpT+c0GukgU18_YEKKWtXVpOk0ePRAtCDU71jqA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 9, 2014 at 4:34 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> How painful would it be to get rid of _PAGE_NUMA entirely?  Page bits
> are a highly precious commodity and saving one would be valuable.

I don't think _PAGE_NUMA is a problem. It's only set when the page is
not present, so we have tons of bits then.

Now, that's still inconvenient for the 32-bit pte case, because we do
*not* have tons of bits for non-present cases since we need them for
the swap indexes.

This is different from _PAGE_SOFT_DIRTY, which we do need for both
present and swapped-out entries.

Or am I missing something?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
