Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 408C46B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 15:09:04 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so7669675wiv.13
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:09:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u18si1442479wiv.33.2014.04.08.12.09.02
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 12:09:02 -0700 (PDT)
Message-ID: <53444926.4020504@redhat.com>
Date: Tue, 08 Apr 2014 15:08:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v2
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>	<53440A5D.6050301@zytor.com>	<CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>	<20140408164652.GL7292@suse.de>	<CA+55aFwrwYmWFXWpPeg-keKukW0=dwvmUBuN4NKA=JcseiUX3g@mail.gmail.com>	<20140408185146.GP7292@suse.de> <CA+55aFwXuwE8=4h2LrjfjjMhE35pj4W6oOXYFuWkkB65eya=XA@mail.gmail.com>
In-Reply-To: <CA+55aFwXuwE8=4h2LrjfjjMhE35pj4W6oOXYFuWkkB65eya=XA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2014 02:55 PM, Linus Torvalds wrote:
> On Tue, Apr 8, 2014 at 11:51 AM, Mel Gorman <mgorman@suse.de> wrote:
>>
>> I picked a solution. The posted series uses a different bit.
> 
> Yes, and I actually like that. I have nothing against your patch
> series. I'm ranting and raving because you then seemed to say "maybe
> we shouldn't pick a solution after all" when you said:

FWIW, Mel's patches look good to me.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
