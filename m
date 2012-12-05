Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CB9786B006C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 22:02:48 -0500 (EST)
Date: Tue, 4 Dec 2012 21:01:33 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121205030133.GA17438@wolff.to>
References: <20121128101359.GT8218@suse.de>
 <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de>
 <50B77F84.1030907@leemhuis.info>
 <20121129170512.GI2301@cmpxchg.org>
 <50B8A8E7.4030108@leemhuis.info>
 <20121201004520.GK2301@cmpxchg.org>
 <50BC6314.7060106@leemhuis.info>
 <20121203194208.GZ24381@cmpxchg.org>
 <20121204214210.GB20253@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20121204214210.GB20253@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Thorsten Leemhuis <fedora@leemhuis.info>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

On Tue, Dec 04, 2012 at 16:42:10 -0500,
   Johannes Weiner <hannes@cmpxchg.org> wrote:
>  kernel-3.7.0-0.rc7.git1.2.van.main.knurd.kswap.4.fc18.i686
>and
>  kernel-3.7.0-0.rc7.git1.2.van.main.knurd.kswap.4.fc18.x86_64
>for over 24hours with no evidence of problems with kswapd"
>
>Now waiting for results from Jiri, Zdenek and Bruno...

I have been running 3.7.0-0.rc7.git1.2.van.main.knurd.kswap.4.fc18.i686.PAE 
a bit over 23 hours and kswapd has accumalated one minute 8 seconds of 
CPU time. I did several yum operations during that time and didn't see 
kswapd spike to 90+% CPU usage as I had seen in the past. With some kernels 
I wasn't reliably triggering the kswapd issue, so it may not be long enough 
to know for sure that the problem is fixed.

I also should note that when I tried 3.7.0-0.rc7.git3.2.fc19.i686.PAE I 
did see problems with kswapd hitting 90+% usage of a CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
