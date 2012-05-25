Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6DD756B00FE
	for <linux-mm@kvack.org>; Fri, 25 May 2012 16:56:18 -0400 (EDT)
Message-ID: <4FBFF1F0.6050802@tilera.com>
Date: Fri, 25 May 2012 16:56:16 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 1/6] timer: make __next_timer_interrupt explicit about
 no future event
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-2-git-send-email-gilad@benyossef.com> <alpine.LFD.2.02.1205251846520.3231@ionos>
In-Reply-To: <alpine.LFD.2.02.1205251846520.3231@ionos>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On 5/25/2012 4:48 PM, Thomas Gleixner wrote:
>> I've noticed a similar but slightly different fix to the
>> > same problem in the Tilera kernel tree from Chris M. (I've
>> > wrote this before seeing that one), so some variation of this
>> > fix is in use on real hardware for some time now.
> Sigh, why can't people post their fixes instead of burying them in
> their private trees?

The tree was never really ready for review.  I pushed the tree just for
reference to the nohz cpusets work, and so that I have something I can
refer people to when I start participating more actively in that discussion.

It didn't seem useful to post a single patch by itself without more
motivating examples behind it (i.e. without the entirety of the tree).

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
