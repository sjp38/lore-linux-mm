Date: Mon, 30 Sep 2002 00:51:39 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.39-mm1
Message-ID: <735786955.1033347097@[10.10.2.3]>
In-Reply-To: <3D976206.B2C6A5B8@digeo.com>
References: <3D976206.B2C6A5B8@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

> I must say that based on a small amount of performance testing the
> benefits of the cache warmness thing are disappointing. Maybe 1% if
> you squint.  Martin, could you please do a before-and-after on the
> NUMAQ's, double check that it is actually doing the right thing?

Seems to work just fine:

2.5.38-mm1 + my original hot/cold code.
Elapsed: 19.798s User: 191.61s System: 43.322s CPU: 1186.4%

2.5.39-mm1
Elapsed: 19.532s User: 192.25s System: 42.642s CPU: 1203.2%

And it's a lot more than 1% for me ;-) About 12% of systime
on kernel compile, IIRC.

M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
