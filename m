Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA25464
	for <linux-mm@kvack.org>; Wed, 2 Oct 2002 14:03:36 -0700 (PDT)
Message-ID: <3D9B5F26.8317692D@digeo.com>
Date: Wed, 02 Oct 2002 14:03:34 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [Lse-tech] Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 +
 rmap, 2.5.35 +mm1, and 2.5.38 + mm3
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com> <3D948EA6.A6EFC26B@austin.ibm.com> <3D94A43B.49C65AE8@digeo.com> <3D9B402D.601E52B6@austin.ibm.com> <3D9B4AC2.4EAF1B85@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Hartner <hartner@austin.ibm.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> I wonder if volanomark does tcp to localhost?  `ifconfig lo' will
> tell us.

OK, I googled up some kernel profiles.  Volanomark does
tcp to localhost.

We'll need kernel profiles to take this further.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
