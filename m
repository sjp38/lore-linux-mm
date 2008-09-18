Message-ID: <48D2A392.6010308@goop.org>
Date: Thu, 18 Sep 2008 11:53:06 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com> <48D17A93.4000803@goop.org> <48D29AFB.5070409@linux-foundation.org>
In-Reply-To: <48D29AFB.5070409@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Chris Snook <csnook@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Martin J. Bligh" <mbligh@google.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> I had a patch like that a couple of years back but it was not accepted.
>
> http://www.kernel.org/pub/linux/kernel/people/christoph/prefault/
>
> http://readlist.com/lists/vger.kernel.org/linux-kernel/14/70942.html
>
> http://www.ussg.iu.edu/hypermail/linux/kernel/0503.1/1292.html
>
>   

Thanks, that was exactly what I was hoping to see.  I didn't see any
definitive statements against the patch set, other than a concern that
it could make things worse.  Was the upshot that no consensus was
reached about how to detect when its beneficial to preallocate anonymous
pages?

Martin, in that thread you mentioned that you had tried pre-populating
file-backed mappings as well, but "Mmmm ... we tried doing this before
for filebacked pages by sniffing the
pagecache, but it crippled forky workloads (like kernel compile) with the
extra cost in zap_pte_range, etc. ".

Could you describe, or have a pointer to, what you tried and how it
turned out?  Did you end up populating so many (unused) ptes that
zap_pte_range needed to do lots more work?

Christoph (and others): do you think vm changes in the last 4 years
would have changed the outcome of these results?


Thanks,
    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
