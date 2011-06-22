Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 117AA900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:31:21 -0400 (EDT)
Message-ID: <4E01D27F.8080304@redhat.com>
Date: Wed, 22 Jun 2011 14:31:11 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com> <4E01CC77.10607@ravellosystems.com> <4E01CDAD.3070202@redhat.com> <4E01CFD2.6000404@ravellosystems.com> <4E01D0E3.9080508@redhat.com> <4E01D1C8.2050707@redhat.com>
In-Reply-To: <4E01D1C8.2050707@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: nai.xia@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/22/2011 02:28 PM, Avi Kivity wrote:
>
> Actually, this is dangerous.  If we use the dirty bit for other 
> things, we will get data corruption.
>
> For example we might want to map clean host pages as writeable-clean 
> in the spte on a read fault so that we don't get a page fault when 
> they get eventually written.
>

Another example - we can use the dirty bit for dirty page loggging.

So I think we can get away with a conditional tlb flush - only flush if 
the page was dirty.  That should be rare after the first pass, at least 
with small pages.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
