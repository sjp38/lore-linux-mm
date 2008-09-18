Date: Fri, 19 Sep 2008 07:21:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Populating multiple ptes at fault time
In-Reply-To: <48D2AE6C.7060507@linux-foundation.org>
References: <48D2A392.6010308@goop.org> <48D2AE6C.7060507@linux-foundation.org>
Message-Id: <20080920191928.50ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeremy Fitzhardinge <jeremy@goop.org>, Chris Snook <csnook@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Martin J. Bligh" <mbligh@google.com>
List-ID: <linux-mm.kvack.org>

> Jeremy Fitzhardinge wrote:
> > Thanks, that was exactly what I was hoping to see.  I didn't see any
> > definitive statements against the patch set, other than a concern that
> > it could make things worse.  Was the upshot that no consensus was
> > reached about how to detect when its beneficial to preallocate anonymous
> > pages?
> 
> There were multiple discussions on the subject. The consensus was that it was
> difficult to generalize this and it would only work on special loads. Plus it
> would add some overhead to the general case.

but at that time, x86_64 large server doesn't exist yet.
I think mesurement again is valuable because typical server environment
is changed in these days.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
