Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA02219
	for <linux-mm@kvack.org>; Thu, 14 Nov 2002 15:21:28 -0800 (PST)
Message-ID: <3DD42FF7.525F2919@digeo.com>
Date: Thu, 14 Nov 2002 15:21:27 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.47-mm2 - oops with scp
References: <1037311851.10626.126.camel@plars>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> This has been opened as bug #21 on bugme.osdl.org.
> http://bugme.osdl.org/show_bug.cgi?id=21
> 
> When trying to scp a file to the victim machine, I got this message then
> the oops:
> 
> Attempt to release alive inet socket cdb59b60
> 

That's a bug I added to tcp_init_xmit_timers().   The right
code is in Linus's tree as of this morning.

I really don't know what I was thinking of, making that change :(
I guess after the thousandth timer, the brain fried.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
