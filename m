Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 38CA46B0044
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 13:56:12 -0500 (EST)
Message-ID: <50BA52B6.2010009@redhat.com>
Date: Sat, 01 Dec 2012 13:55:50 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm/migration: Remove anon vma locking from try_to_unmap()
 use
References: <1354305521-11583-1-git-send-email-mingo@kernel.org> <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com> <20121201094927.GA12366@gmail.com> <20121201122649.GA20322@gmail.com> <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
In-Reply-To: <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/01/2012 01:38 PM, Linus Torvalds wrote:
> On Sat, Dec 1, 2012 at 4:26 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>
>>
>> So as a quick concept hack I wrote the patch attached below.
>> (It's not signed off, see the patch description text for the
>> reason.)
>
> Well, it confirms that anon_vma locking is a big problem, but as
> outlined in my other email it's completely incorrect from an actual
> behavior standpoint.
>
> Btw, I think the anon_vma lock could be made a spinlock

The anon_vma lock used to be a spinlock, and was turned into a
mutex by Peter, as part of an effort to make more of the VM
preemptible.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
