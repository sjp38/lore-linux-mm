Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 487B96B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 20:41:01 -0400 (EDT)
Message-ID: <50946810.7010308@redhat.com>
Date: Fri, 02 Nov 2012 20:40:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/6] mm: vm_unmapped_area() lookup function
References: <1351679605-4816-1-git-send-email-walken@google.com> <1351679605-4816-5-git-send-email-walken@google.com> <5093FA42.50806@redhat.com> <CANN689Gy9izaMwrOfHi2wRcGD8Mi_x_m89YEj7qd4oyuMVCpZA@mail.gmail.com>
In-Reply-To: <CANN689Gy9izaMwrOfHi2wRcGD8Mi_x_m89YEj7qd4oyuMVCpZA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 11/02/2012 06:41 PM, Michel Lespinasse wrote:
> On Fri, Nov 2, 2012 at 9:52 AM, Rik van Riel <riel@redhat.com> wrote:
>> On 10/31/2012 06:33 AM, Michel Lespinasse wrote:

> I guess the suggestion is OK in the sense that I can't see a case
> where it'd hurt. However, it still won't find all cases where we just
> unmapped a region of size N with the correct alignment - it could be
> that the first region we find has insufficient alignment, and then the
> search with an increased length could fail, even though there exists
> an aligned gap (just not the first) of the desired size. So, this is
> only a partial solution.

> Unfortunately, I don't think there is an efficient solution to the
> general problem, and the partial solutions discussed above (both yours
> and mine) don't seem to cover enough cases to warrant the complexity
> IMO...

The common case (anonymous memory) is that no alignment is
required, so your solution and mine would be equivalent :)

You are right that your solution and mine are pretty
much the same for the (rarer) cases where alignment
is needed.  Lets stick with your simpler version.

ACK to your version

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
