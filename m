Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA24930
	for <linux-mm@kvack.org>; Thu, 7 Nov 2002 09:13:53 -0800 (PST)
Message-ID: <3DCA9F50.1A9E5EC5@digeo.com>
Date: Thu, 07 Nov 2002 09:13:52 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.46-mm1
References: <Pine.LNX.3.96.1021107113557.30525C-100000@gatekeeper.tmr.com> <4051130868.1036659083@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Bill Davidsen <davidsen@tmr.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > For what it's worth, the last mm kernel which booted on my old P-II IDE
> > test machine was 44-mm2. With 44-mm6 and this one I get an oops on boot.
> > Unfortunately it isn't written to disk, scrolls off the console, and
> > leaves the machine totally dead to anything less than a reset. I will try
> 
> Any chance of setting up a serial console? They're very handy for
> things like this ...
> 

"vga=extended" gets you 50 rows, which is usually enough.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
