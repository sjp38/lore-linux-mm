Date: Thu, 10 Nov 2005 19:40:39 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[0/5]
Message-Id: <20051110185754.0230.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hello.

I rewrote patches to create new zone as ZONE_EASY_RECLAIM.

Probably, many guys of here remember the discussion about
Mel-san's "fragmentation avoidance" patch in the last week.
In the discussion, another way was creating new zone like these patch
which I posted one years ago. 

http://sourceforge.net/mailarchive/forum.php?thread_id=5969508&forum_id=223

My motivation of creating new zone was for memory hotplug.
(Previous name of the zone was ZONE_REMOVABLE.)
It aimed to collect the page which was difficult for removing on few nodes,
and it made other nodes this zone to be removed easier.

But, I thought Mell-san's patch is also useful for this purpose.
So, I stopped my work about it after his patch was introduced.
Howerver unfortunately, Linus-san didn't agree his patches at last week.
So, I felt my old work should be restarted.

Frankly, I don't see that my patch set is/will be the best way
for others. My patch didn't concern about fragmentation.
And this patch has pros and cons as Mel-san said.
But I realize each persons are expecting against new zone for each reason.
So, I changed the name of new zone as ZONE_EASY_RECLAIM.
I wish this become good start point for them to be able to be happy.

This patch is for 2.6.14.

Please comment.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
