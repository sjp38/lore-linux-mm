Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0B0EA6B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:50:01 -0400 (EDT)
Received: by qabg27 with SMTP id g27so2848107qab.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 23:50:01 -0700 (PDT)
Message-ID: <4FC71496.8050707@gmail.com>
Date: Thu, 31 May 2012 02:49:58 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split
 handle vma->vm_policy linkages"
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1205301414020.31768@router.home>
In-Reply-To: <alpine.DEB.2.00.1205301414020.31768@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

(5/30/12 3:17 PM), Christoph Lameter wrote:
> On Wed, 30 May 2012, kosaki.motohiro@gmail.com wrote:
>
>> From: KOSAKI Motohiro<kosaki.motohiro@gmail.com>
>>
>> commit 05f144a0d5 removed vma->vm_policy updates code and it is a purpose of
>> mbind_range(). Now, mbind_range() is virtually no-op. no-op function don't
>> makes any bugs, I agree. but maybe it is not right fix.
>
> I dont really understand the changelog. But to restore the policy_vma() is
> the right thing to do since there are potential multiple use cases where
> we want to apply a policy to a vma.
>
> Proposed new changelog:
>
> Commit 05f144a0d5 folded policy_vma() into mbind_range(). There are
> other use cases of policy_vma(*) though and so revert a piece of
> that commit in order to have a policy_vma() function again.

sorry, I overlooked this. Commit 05f144a0d5 don't work neither regular vma
nor shmem vma. thus I can't take this proposal. sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
