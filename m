Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DGqLC0018118
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 12:52:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6DGqL1a477544
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 12:52:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DGqLbh019445
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 12:52:21 -0400
Date: Fri, 13 Jul 2007 09:52:16 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
Message-ID: <20070713165216.GH10067@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070713151431.GG10067@us.ibm.com> <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 13.07.2007 [09:43:25 -0700], Christoph Lameter wrote:
> On Fri, 13 Jul 2007, Nishanth Aravamudan wrote:
> 
> > On 11.07.2007 [11:22:19 -0700], Christoph Lameter wrote:
> > > Changes V2->V3:
> > > - Refresh patches (sigh)
> > > - Add comments suggested by Kamezawa Hiroyuki
> > > - Add signoff by Jes Sorensen
> > 
> > Christoph, would it be possible to get the current patches up on
> > kernel.org in your people-space? That way I know I have the current
> > versions of these, including any fixlets that come by?
> 
> Lee: Would you repost the patches after testing them and fixing them up? 

That will work too.

> You probably have somewhere to publish them? I will be on vacation
> next week (and yes I will leave my laptop at home, somehow I have to
> get back my sanity).

Enjoy your vacation and good luck with the sanity :) Thanks again for
working through these memoryless node issues.

-Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
