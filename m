Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA03007
	for <linux-mm@kvack.org>; Fri, 27 Sep 2002 11:32:20 -0700 (PDT)
Message-ID: <3D94A43B.49C65AE8@digeo.com>
Date: Fri, 27 Sep 2002 11:32:27 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35,and  
 2.5.35 + mm1
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com> <3D948EA6.A6EFC26B@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Hartner <hartner@austin.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Bill Hartner wrote:
> 
> ...
> 2.5.35       44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
> 2.5.35mm1    39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB
> 

2.5.35 was fairly wretched from the swapout point of view.
Would be interesting to retest on 2.5.38-mm/2.5.39 sometime.

(This always happens, sorry.  But stuff is changing fast)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
