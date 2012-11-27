Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C25EA6B009C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:20:01 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so4110078wey.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:20:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121127222637.GG2301@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
 <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
 <50B52DC4.5000109@redhat.com> <20121127214928.GA20253@cmpxchg.org>
 <50B5387C.1030005@redhat.com> <20121127222637.GG2301@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Nov 2012 15:19:38 -0800
Message-ID: <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Nov 27, 2012 at 2:26 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Nov 27, 2012 at 05:02:36PM -0500, Rik van Riel wrote:
>>
>> Kswapd going crazy is certainly a large part of the problem.
>>
>> However, that leaves the issue of page_alloc.c waking up
>> kswapd when the system is not actually low on memory.
>>
>> Instead, kswapd is woken up because memory compaction failed,
>> potentially even due to lock contention during compaction!
>>
>> Ideally the allocation code would only wake up kswapd if
>> memory needs to be freed, or in order for kswapd to do
>> memory compaction (so the allocator does not have to).
>
> Maybe I missed something, but shouldn't this be solved with my patch?

Ok, guys. Cage fight!

The rules are simple: two men enter, one man leaves.

And the one who comes out gets to explain to me which patch(es) I
should apply, and which I should revert, if any.

My current guess is that I should apply the one Johannes just sent
("mm: vmscan: fix kswapd endless loop on higher order allocation")
after having added the cc to stable to it, and then revert the recent
revert (commit 82b212f40059).

But I await the Thunderdome. <Cue Tina Turner "We Don't Need Another Hero">

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
