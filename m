Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA10926
	for <linux-mm@kvack.org>; Thu, 27 Aug 1998 08:21:52 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> <199808271207.OAA15842@hwal02.hyperwave.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 27 Aug 1998 14:21:35 +0200
In-Reply-To: Bernhard Heidegger's message of "Thu, 27 Aug 1998 14:07:32 +0200 (MET DST)"
Message-ID: <87emu2zkc0.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Bernhard Heidegger <bheide@hyperwave.com>
Cc: "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Bernhard Heidegger <bheide@hyperwave.com> writes:

> >>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> 
> >> "H. Peter Anvin" <hpa@transmeta.com> writes:
> >> > 
> >> > bdflush yes, but update is not obsolete.
> >> > 
> >> > It is still needed if you want to make sure data (and metadata)
> >> > eventually gets written to disk.
> >> > 
> >> > Of course, you can run without update, but then don't bother if you
> >> > lose file in system crash, even if you edited it and saved it few
> >> > hours ago. :)
> >> > 
> >> > Update is very important if you have lots of RAM in your computer.
> >> > 
> >> 
> >> Oh.  I guess my next question then is "why", as why can't this be done
> >> by kflushd as well?
> >> 
> 
> >> To tell you the truth, I'm not sure why, these days.
> 
> >> I thought it was done this way (update running in userspace) so to
> >> have control how often buffers get flushed. But, I believe bdflush
> >> program had this functionality, and it is long gone (as you correctly
> >> noticed).
> 
> IMHO, update/bdflush (in user space) calls sys_bdflush regularly. This
> function (fs/buffer.c) calls sync_old_buffers() which itself sync_supers
> and sync_inodes before it goes through the dirty buffer lust (to write
> some dirty buffers); the kflushd only writes some dirty buffers dependent
> on the sysctl parameters.
> If I'm wrong, please feel free to correct me!
> 

You are not wrong.

Update flushes metadata blocks every 5 seconds, and data block every
30 seconds.

Questions is why can't this functionality be integrated in the kernel, 
so we don't have to run yet another daemon?

As parameters are easy controllable with sysctl interface, I don't see
a reason why is update still needed. Or is it not?
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	There is an exception to every rule, except this one.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
