Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id EA4B66B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 14:55:22 -0400 (EDT)
Received: by mail-ve0-f173.google.com with SMTP id oy12so1152598veb.18
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 11:55:22 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id fa16si571250veb.82.2014.04.08.11.55.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 11:55:22 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id lf12so1133074vcb.39
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 11:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140408185146.GP7292@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
	<53440A5D.6050301@zytor.com>
	<CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
	<20140408164652.GL7292@suse.de>
	<CA+55aFwrwYmWFXWpPeg-keKukW0=dwvmUBuN4NKA=JcseiUX3g@mail.gmail.com>
	<20140408185146.GP7292@suse.de>
Date: Tue, 8 Apr 2014 11:55:22 -0700
Message-ID: <CA+55aFwXuwE8=4h2LrjfjjMhE35pj4W6oOXYFuWkkB65eya=XA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 8, 2014 at 11:51 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> I picked a solution. The posted series uses a different bit.

Yes, and I actually like that. I have nothing against your patch
series. I'm ranting and raving because you then seemed to say "maybe
we shouldn't pick a solution after all" when you said:

> > If you are ok with leaving _PAGE_NUMA as _PAGE_PROTNONE

which was what I reacted to.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
