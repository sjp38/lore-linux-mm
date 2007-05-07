Date: Mon, 07 May 2007 22:07:36 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: fragmentation avoidance Re: 2.6.22 -mm merge plans
In-Reply-To: <20070501101651.GA29957@skynet.ie>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501101651.GA29957@skynet.ie>
Message-Id: <20070507211327.3129.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Sorry for late response. I went on a vacation in last week.
And I'm in the mountain of a ton of unread mail now....

> > Mel's moveable-zone work.
> 
> These patches are what creates ZONE_MOVABLE. The last 6 patches should be
> collapsed into a single patch:
> 
> 	handle-kernelcore=-generic
> 
> I believe Yasunori Goto is looking at these from the perspective of memory
> hot-remove and has caught a few bugs in the past. Goto-san may be able to
> comment on whether they have been reviewed recently.

Hmm, I don't think my review is enough.
To be precise, I'm just one user/tester of ZONE_MOVABLE.
I have tried to make memory remove patches with Mel-san's
ZONE_MOVABLE patch. And the bugs are things that I found in its work.
(I'll post these patches in a few days.)

> The main complexity is in one function in patch one which determines where
> the PFN is in each node for ZONE_MOVABLE. Getting that right so that the
> requested amount of kernel memory spread as evenly as possible is just
> not straight-forward.

>From memory-hotplug view, ZONE_MOVABLE should be aligned by section
size. But MAX_ORDER alignment is enough for others...

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
