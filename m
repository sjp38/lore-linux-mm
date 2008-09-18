Message-ID: <48D2AE6C.7060507@linux-foundation.org>
Date: Thu, 18 Sep 2008 14:39:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com> <48D17A93.4000803@goop.org> <48D29AFB.5070409@linux-foundation.org> <48D2A392.6010308@goop.org>
In-Reply-To: <48D2A392.6010308@goop.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Snook <csnook@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Martin J. Bligh" <mbligh@google.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Thanks, that was exactly what I was hoping to see.  I didn't see any
> definitive statements against the patch set, other than a concern that
> it could make things worse.  Was the upshot that no consensus was
> reached about how to detect when its beneficial to preallocate anonymous
> pages?

There were multiple discussions on the subject. The consensus was that it was
difficult to generalize this and it would only work on special loads. Plus it
would add some overhead to the general case.

> Christoph (and others): do you think vm changes in the last 4 years
> would have changed the outcome of these results?

Seems that the code today is similar. So it would still work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
