Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA20882
	for <linux-mm@kvack.org>; Mon, 30 Sep 2002 01:01:40 -0700 (PDT)
Message-ID: <3D9804E1.76C9D4AE@digeo.com>
Date: Mon, 30 Sep 2002 01:01:37 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.39-mm1
References: <3D976206.B2C6A5B8@digeo.com> <735786955.1033347097@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > I must say that based on a small amount of performance testing the
> > benefits of the cache warmness thing are disappointing. Maybe 1% if
> > you squint.  Martin, could you please do a before-and-after on the
> > NUMAQ's, double check that it is actually doing the right thing?
> 
> Seems to work just fine:
> 
> 2.5.38-mm1 + my original hot/cold code.
> Elapsed: 19.798s User: 191.61s System: 43.322s CPU: 1186.4%
> 
> 2.5.39-mm1
> Elapsed: 19.532s User: 192.25s System: 42.642s CPU: 1203.2%
> 
> And it's a lot more than 1% for me ;-) About 12% of systime
> on kernel compile, IIRC.

Well that's still a 1% bottom line.  But we don't have a
comparison which shows the effects of this patch alone.

Can you patch -R the five patches and retest sometime?

I just get the feeling that it should be doing better.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
