Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E99716B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 03:06:40 -0500 (EST)
Date: Fri, 18 Dec 2009 09:06:31 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
Message-ID: <20091218080631.GA1374@ucw.cz>
References: <23e2d3ad-2611-4422-9349-50e4d3d8377f@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23e2d3ad-2611-4422-9349-50e4d3d8377f@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

Hi!

> Performance is difficult to quantify because some benchmarks respond
> very favorably to increases in memory and tmem may do quite well on
> those, depending on how much tmem is available which may vary widely
> and dynamically, depending on conditions completely outside of the
> system being measured.  Ideas on how best to provide useful metrics
> would be appreciated.

So... take 1GB system, run your favourite benchmark. Then reserve
512MB for tmem, rerun your benchmark, then run the system with
512MB/512MB swap, rerun the benchmark?

Tune the sizes so that first to last run differ by 100% or so, and see
how much first and second differs? If it is in 1% range, you are
probably doing good...?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
