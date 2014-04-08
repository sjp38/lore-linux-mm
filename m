Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id D72D56B0037
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:06:13 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so859943eek.38
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:06:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 45si3346796eeh.243.2014.04.08.09.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 09:06:10 -0700 (PDT)
Message-ID: <53441E19.8090004@zytor.com>
Date: Tue, 08 Apr 2014 09:04:41 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v2
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>	<53440A5D.6050301@zytor.com> <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
In-Reply-To: <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2014 08:22 AM, Linus Torvalds wrote:
> On Tue, Apr 8, 2014 at 7:40 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>
>> David, is your patchset going to be pushed in this merge window as expected?
> 
> Apparently aiming for 3.16 right now.
> 
>> That being said, these bits are precious, and if this ends up being a
>> case where "only Xen needs another bit" once again then Xen should
>> expect to get kicked to the curb at a moment's notice.
> 
> Quite frankly, I don't think it's a Xen-only issue. The code was hard
> to figure out even without the Xen issues. For example, nobody ever
> explained to me why it
> 
>  (a) could be the same as PROTNONE on x86
>  (b) could not be the same as PROTNONE in general
> 
> I think the best explanation for it so far was from the little voices
> in my head that sang "It's a kind of Magic", and that isn't even
> remotely the best song by Queen.
> 

Yes, I was hoping that the timing would work out so we could evict bit
10 (which *is* a Xen-only issue) and then reuse it.  I don't think the
NUMA bit is Xen-only.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
