Subject: Re: Hangs in 2.5.41-mm1
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <3DA48EEA.8100302C@digeo.com>
References: <1034188573.30975.40.camel@plars>  <3DA48EEA.8100302C@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 09 Oct 2002 15:29:28 -0500
Message-Id: <1034195372.30973.64.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-09 at 15:17, Andrew Morton wrote:
> Paul Larson wrote:
> > echo 768 > /proc/sys/vm/nr_hugepages
> 
> Paul, this is not very clear to me, sorry.
Sorry about that, let me try to restate it better.  First let me add
though, these have been somewhat random and hard to reproduce the same
way every time, but if I run this test enough though, I eventually get
it to lock up cold.

Here are the situations where I saw it happen so far under 2.5.41-mm1:

Case 1:
from ltp, 'runalltests.sh -l /tmp/mm1.log |tee /tmp/mm1.out
shmt01 (attached test from before)
shmt01& (repeated 10 times)
echo 768 > /proc/sys/vm/nr_hugepages
*hang*

Case 2:
cold boot
echo 768 > /proc/sys/vm/nr_hugepages
echo 1610612736 > /proc/sys/kernel/shmmax
shmt01 -s 1610612736&
shmt01 (immediately after starting the previous command)
*hang*

> There is a locks-up-for-ages bug in refill_inactive_zone() - could
> be that.  Dunno.
I'm not aware of that one, do you know of a reliable way to reproduce that?

Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
