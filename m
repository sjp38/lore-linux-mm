Message-ID: <45D5152B.1010401@mbligh.org>
Date: Thu, 15 Feb 2007 18:21:31 -0800
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>	<20070215171355.67c7e8b4.akpm@linux-foundation.org>	<45D50B79.5080002@mbligh.org> <20070215174957.f1fb8711.akpm@linux-foundation.org>
In-Reply-To: <20070215174957.f1fb8711.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>>> #define PageMlocked(page)	(page->lru.next == some_address_which_isnt_used_for_anwything_else)
>> Mine just created a locked list. If you stick them there, there's no
>> need for a page flag ... and we don't abuse the lru pointers AGAIN! ;-)
> 
> I don't think there's a need for a mlocked list in the mlock patches:
> nothing ever needs to walk it.
> 
> However this might be a good way of solving the someone-did-a-swapon
> problem for this anon patch.
> 
> Guys, this page-flag problem is really serious.  -mm adds PG_mlocked and
> PG_readahead and the ext4 patches add PG_booked (am currently fighting the
> good fight there).  There's ongoing steady growth in these things and soon
> we're going to be in a lot of pain.

Well, if the list is sufficient to fix that, I don't see why we'd
care about the overhead of list manipulation vs a flag, it's not
a fast path.

>> Suspect most of the rest of my patch is crap, but that might be useful?
> 
> wordwrapped, space-stuffed and tab-replaced.  The trifecta!

That's cause it was fairly obviously useless as-was so I just cut
and pasted it. But nonetheless, I appreciate your adulation ;-)

I'll try to add CamelCaps, bracing fuckups, and lots of #ifdefs
for the next round.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
