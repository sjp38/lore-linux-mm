Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m0HHg7QO031706
	for <linux-mm@kvack.org>; Fri, 18 Jan 2008 04:42:07 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0HHk0PD278898
	for <linux-mm@kvack.org>; Fri, 18 Jan 2008 04:46:00 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0HHgN34012226
	for <linux-mm@kvack.org>; Fri, 18 Jan 2008 04:42:24 +1100
Date: Thu, 17 Jan 2008 23:12:15 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG] at mm/slab.c:3320
Message-ID: <20080117174215.GD6667@skywalker>
References: <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com> <20080109221315.GB26941@us.ibm.com> <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com> <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com> <Pine.LNX.4.64.0801170631000.19208@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801171634530.27536@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0801170705210.19928@schroedinger.engr.sgi.com> <20080117152524.GB6667@skywalker> <Pine.LNX.4.64.0801170857520.20366@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801170857520.20366@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 08:58:05AM -0800, Christoph Lameter wrote:
> On Thu, 17 Jan 2008, Aneesh Kumar K.V wrote:
> 
> > I have already updated the problem still exist
> > 
> > http://marc.info/?l=linux-mm&m=119990525620006&w=2
> 
> Wasnt that an earlier version of the patch?
> 

Yes. Right now waiting for the machine to be free to start the test.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
