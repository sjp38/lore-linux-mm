Date: Fri, 14 Feb 2003 09:38:56 +0000
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 2.5.60-mm2
Message-ID: <20030214093856.GC13845@codemonkey.org.uk>
References: <20030214013144.2d94a9c5.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030214013144.2d94a9c5.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 14, 2003 at 01:31:44AM -0800, Andrew Morton wrote:

 > . Considerable poking at the NFS MAP_SHARED OOM lockup.  It is limping
 >   along now, but writeout bandwidth is poor and it is still struggling. 
 >   Needs work.
 > 
 > . There's a one-liner which removes an O(n^2) search in the NFS writeback
 >   path.  It increases writeout bandwidth by 4x and decreases CPU load from
 >   100% to 3%.  Needs work.

I'm puzzled that you've had NFS stable enough to test these.
How much testing has this stuff had? Here 2.5.60+bk clients fall over under
moderate NFS load. (And go splat quickly under high load).

Trying to run things like dbench causes lockups, fsx/fstress made it
reboot, plus the odd 'cheating' errors reported yesterday.

		Dave

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
