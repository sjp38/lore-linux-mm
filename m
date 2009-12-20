Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA956B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 07:00:50 -0500 (EST)
Date: Sun, 20 Dec 2009 13:00:43 +0100
From: Attila Kinali <attila@kinali.ch>
Subject: Re: page allocation failure - still unfixed in 2.6.32.1
Message-Id: <20091220130043.dac8aa88.attila@kinali.ch>
In-Reply-To: <alpine.DEB.1.10.0912201250310.23464@uplift.swm.pp.se>
References: <20091220124721.006da86a.attila@kinali.ch>
	<alpine.DEB.1.10.0912201250310.23464@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Dec 2009 12:52:23 +0100 (CET)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> > The page allocation failure that was introduced in 2.6.31 and
> > which has been discussed here a few times, is still present in
> > 2.6.32.1. I can still (more or less) reproduce it on my home-fileserver:
> >
> > Dec 20 11:43:14 koyomi kernel: swapper: page allocation failure. order:3, mode:0x20
> > Dec 20 11:43:14 koyomi kernel: Pid: 0, comm: swapper Not tainted 2.6.32.1 #1
> > Dec 20 11:43:14 koyomi kernel: Call Trace:
> 
> Are you sure these are new? I've been seeing them sporadically for years, 
> this latest one is on 2.6.28. They seem to happen whenever there are lots 
> of TCP sessions going, and I have raised the default TCP parameters for 
> long latency performance.

Yes. I didn't see any such problems until i updated to 2.6.30.x.
And as the machine is mostly used for NFSv3, 99% of the traffic
is UDP and not TCP. 
A quick count shows currently 17 TCP connections running. 
So i dont think i'd hit any limit there.

			Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
