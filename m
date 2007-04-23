Message-ID: <462C8922.7070401@shadowen.org>
Date: Mon, 23 Apr 2007 11:23:30 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] introduce HIGH_ORDER delineating easily reclaimable
 orders
References: <exportbomb.1177081388@pinky>	<cc3c22ba296c3d75cd7bd66747fb08c0@pinky>	<20070421012843.f5a814eb.akpm@linux-foundation.org> <20070421013210.1bed9ceb.akpm@linux-foundation.org>
In-Reply-To: <20070421013210.1bed9ceb.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sat, 21 Apr 2007 01:28:43 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> It would have been better to have patched page_alloc.c independently, then
>> to have used HIGH_ORDER in "lumpy: increase pressure at the end of the inactive
>> list".
> 
> Actually that doesn't matter, because I plan on lumping all the lumpy patches
> together into one lump.
> 
> I was going to duck patches #2 and #3, such was my outrage.  But given that
> it's all lined up to be a single patch, followup cleanup patches will fit in
> OK.  Please.

Yes.  Its funny how you can get so close to a change that you can no
longer see the obvious warts on it.

I am actually travelling today, so it'll be tommorrow now.  But I'll
roll the cleanups and get them to you.  I can also offer you a clean
drop in lumpy stack with the HIGH_ORDER change pulled out to the top
once you are happy.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
