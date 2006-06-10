Message-ID: <448A79C9.5000500@yahoo.com.au>
Date: Sat, 10 Jun 2006 17:50:33 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: merging swap prefetching
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Con Kolivas <kernel@kolivas.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <Linux-Kernel@Vger.Kernel.ORG>
List-ID: <linux-mm.kvack.org>

I wasn't aware there was a push to merge swap prefetching in
2.6.18, until the -mm merge plans post.

I would have expected to see some numbers, however I guess the
"merge unless proven bad" approach for new features works too.

I had a quick look at the code, and I think it still needs
more cleanup and review... it is vaguely difficult to participate
in discussions about these patches because they are often split
over several iterations of versions/fixes, and because it isn't
always clear what they depend on (although in the case of swap
prefetching, that isn't so much of a problem).

And also, there is no linux-mm thread to reply to... could we
have some of the intrusive mm/ patches intended for 2.6.18
posted here before they get merged, or is that too much trouble?

As far as swap prefetching itself goes, I still don't like it
much (same issues still stand), but with some cleaning up the
patch shouldn't be too bad, and I can turn it off... so if people
want it and if numbers show it is working, I wouldn't object.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
