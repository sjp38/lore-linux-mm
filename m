Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 722A56B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:21:30 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2CLHAlD006536
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:17:10 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CLLQGo221982
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:21:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CLLPU3016903
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:21:26 -0600
Date: Thu, 12 Mar 2009 16:21:24 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090312212124.GA25019@us.ibm.com>
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1236891719.32630.14.camel@bahia>
Sender: owner-linux-mm@kvack.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Cedric Le Goater <legoater@free.fr>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Quoting Greg Kurz (gkurz@fr.ibm.com):
> On Thu, 2009-03-12 at 09:53 -0500, Serge E. Hallyn wrote:
> > Or are you suggesting that you'll do a dummy clone of (5594,2) so that
> > the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?
> > 
> 
> Of course not

Ok - someone *did* argue that at some point I think...

> but one should be able to tell clone() to pick a specific
> pid.

Can you explain exactly how?  I must be missing something clever.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
