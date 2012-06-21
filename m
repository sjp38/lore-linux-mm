Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F3FEE6B00EB
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 15:06:25 -0400 (EDT)
Message-ID: <4FE350D1.4070503@redhat.com>
Date: Thu, 21 Jun 2012 12:50:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
References: <1340057126-31143-1-git-send-email-riel@redhat.com> <1340057126-31143-3-git-send-email-riel@redhat.com> <20120621090157.GG27816@cmpxchg.org>
In-Reply-To: <20120621090157.GG27816@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/21/2012 05:01 AM, Johannes Weiner wrote:

>> +		/* Go left if it looks promising. */
>> +		if (node_free_hole(rb_node->rb_left)>= len&&
>> +					vma->vm_start - len>= lower_limit) {
>> +			rb_node = rb_node->rb_left;
>> +			continue;
>
> If we already are at a vma whose start has a lower address than the
> overall length, does it make sense to check for a left hole?
> I.e. shouldn't this be inside the if (vma->vm_start>  len) block?

You are right, I can move this in under the
conditional.

>> +		if (!found_here&&  node_free_hole(rb_node->rb_left)>= len) {
>> +			/* Last known hole is to the right of this subtree. */
>
> "to the left"

Actually, it is to the right.  We walked left from
our parent to get here, so the holes found so far
are to the right of here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
