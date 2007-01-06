Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l064rTxk027935
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 23:53:29 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l064rRE2483572
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 21:53:29 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l064rQAD028286
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 21:53:27 -0700
Subject: Re: [PATCH] Fix sparsemem on Cell (take 3)
From: John Rose <johnrose@austin.ibm.com>
In-Reply-To: <1168045803.8945.14.camel@localhost.localdomain>
References: <20061215165335.61D9F775@localhost.localdomain>
	 <200612182354.47685.arnd@arndb.de>
	 <1166483780.8648.26.camel@localhost.localdomain>
	 <200612190959.47344.arnd@arndb.de>
	 <1168045803.8945.14.camel@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1168059162.23226.1.camel@sinatra.austin.ibm.com>
Mime-Version: 1.0
Date: Fri, 05 Jan 2007 22:52:42 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, External List <linuxppc-dev@ozlabs.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, kmannth@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, hch@infradead.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, mkravetz@us.ibm.com, gone@us.ibm.com, cbe-oss-dev@ozlabs.org, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

> I dropped this on the floor over Christmas.  This has had a few smoke
> tests on ppc64 and i386 and is ready for -mm.  Against 2.6.20-rc2-mm1.

Could this break ia64, given that it uses memmap_init_zone()?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
