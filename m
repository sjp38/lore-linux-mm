Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA07375
	for <linux-mm@kvack.org>; Wed, 26 Aug 1998 18:50:07 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 27 Aug 1998 00:49:55 +0200
In-Reply-To: "H. Peter Anvin"'s message of "Wed, 26 Aug 1998 14:53:11 -0700 (PDT)"
Message-ID: <87ww7v73zg.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@transmeta.com>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"H. Peter Anvin" <hpa@transmeta.com> writes:

> > 
> > bdflush yes, but update is not obsolete.
> > 
> > It is still needed if you want to make sure data (and metadata)
> > eventually gets written to disk.
> > 
> > Of course, you can run without update, but then don't bother if you
> > lose file in system crash, even if you edited it and saved it few
> > hours ago. :)
> > 
> > Update is very important if you have lots of RAM in your computer.
> > 
> 
> Oh.  I guess my next question then is "why", as why can't this be done
> by kflushd as well?
> 

To tell you the truth, I'm not sure why, these days.

I thought it was done this way (update running in userspace) so to
have control how often buffers get flushed. But, I believe bdflush
program had this functionality, and it is long gone (as you correctly
noticed).

These days, however, we have sysctl thing that is usable for about
anything, and especially for things like this.

Peeking at /proc/sys/vm/bdflush, I can see all needed variables are
already there, so nothing stops kernel to (ab)use them.

{atlas} [/proc/sys/vm]# cat bdflush
40      500     64      256     15      3000    500     1884    2

I'm crossposting this mail to linux-mm where some clever MM people can
be found. Hopefully we can get an explanation why do we still need
update.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
       Linux, WinNT and MS-DOS. The Good, The Bad and The Ugly.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
