Message-ID: <486B0B0F.5010605@qumranet.com>
Date: Wed, 02 Jul 2008 07:58:55 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0 of 3] mmu notifier v18 for -mm
References: <patchbomb.1214440016@duo.random> <20080701214415.b3f93706.akpm@linux-foundation.org>
In-Reply-To: <20080701214415.b3f93706.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 26 Jun 2008 02:26:56 +0200 Andrea Arcangeli <andrea@qumranet.com> wrote:
>
>   
>> Hello,
>>
>> Christoph suggested me to repost v18 for merging in -mm, to give it more
>> exposure before the .27 merge window opens. There's no code change compared to
>> the previous v18 submission (the only change is the correction in the comment
>> in the mm_take_all_locks patch rightfully pointed out by Linus).
>>
>> Full patchset including other XPMEM support patches can be found here:
>>
>> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.26-rc7/mmu-notifier-v18
>>
>> Only the three patches of the patchset I'm submitting here by email are ready
>> for merging, the rest you can find in the website is not ready for merging yet
>> for various performance degradations, lots of the XPMEM patches needs to be
>> elaborated to avoid any slowdown for the non-XPMEM case, but I keep
>> maintaining them to make life easier to XPMEM current development and later we
>> can keep work on them to make them suitable for inclusion to avoid any
>> performance degradation risk.
>>     
>
> I'm a bit concerned about merging the first three patches when there
> are eleven more patches of which some, afacit, are required to make
> these three actually useful.  Committing these three would be signing a
> blank cheque.
>
>   

The first three are useful for kvm, gru, and likely drm and rdma nics.

It is only xpmem which requires the other eleven patches.

> Because if we hit strong objections with the later patches we end up in a
> cant-go-forward, cant-go-backward situation.
>
>   

No, we end up in a some-people-are-happy, 
some-have-to-redo-their-homework situation.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
