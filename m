Date: Fri, 30 May 2003 13:30:15 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm2
Message-Id: <20030530133015.4f305808.akpm@digeo.com>
In-Reply-To: <16087.47491.603116.892709@gargle.gargle.HOWL>
References: <20030529012914.2c315dad.akpm@digeo.com>
	<20030529042333.3dd62255.akpm@digeo.com>
	<16087.47491.603116.892709@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <stoffel@lucent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"John Stoffel" <stoffel@lucent.com> wrote:
>
> >>>>> "Andrew" == Andrew Morton <akpm@digeo.com> writes:
> 
> >> . A couple more locking mistakes in ext3 have been fixed.
> 
> Andrew> But not all of them.  The below is needed on SMP.
> 
> Any hint on when -mm3 will be out,

About ten hours hence, probably.

> and if it will include the RAID1 patches?

I have a raid0 patch from Neil, but no raid1 patch.  I saw one drift past,
from Zwane (I think), but wasn't sure that it worked.  If someone has a
raid1 fix, please send it.

> I haven't had time to play with -mm2, and all the stuff
> floating by about problems has made me a bit hesitant to try it out.

Welll ext3 has been a bit bumpy of course.  It's getting better, but I
haven't yet been able to give it a 12-hour bash on the 4-way.  Last time I
tried a circuit breaker conked; it lasted three hours but even ext3 needs
electricity.  But three hours is very positive - it was hard testing.

I'm not testing RAID at present, partly because I'm too stoopid to
understand mdadm and partly because the box-with-18-disks heats the room up
too much.  This needs to change, because of possible interaction between
the IO scheduler work and software RAID.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
