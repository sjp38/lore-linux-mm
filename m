Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id k8KJp36g001521
	for <linux-mm@kvack.org>; Wed, 20 Sep 2006 12:51:03 -0700
Received: from smtp-out2.google.com (fpr16.prod.google.com [10.253.18.16])
	by zps36.corp.google.com with ESMTP id k8KGWCJj027236
	for <linux-mm@kvack.org>; Wed, 20 Sep 2006 12:51:00 -0700
Received: by smtp-out2.google.com with SMTP id 16so348821fpr
        for <linux-mm@kvack.org>; Wed, 20 Sep 2006 12:51:00 -0700 (PDT)
Message-ID: <6599ad830609201251l3684c0d5q7ce6d054470a8663@mail.google.com>
Date: Wed, 20 Sep 2006 12:51:00 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [ckrm-tech] [patch00/05]: Containers(V2)- Introduction
In-Reply-To: <Pine.LNX.4.64.0609201247300.32409@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>
	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
	 <451173B5.1000805@yahoo.com.au>
	 <1158774657.8574.65.camel@galaxy.corp.google.com>
	 <Pine.LNX.4.64.0609201051550.31636@schroedinger.engr.sgi.com>
	 <1158775586.28174.27.camel@lappy>
	 <Pine.LNX.4.64.0609201247300.32409@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Rohit Seth <rohitseth@google.com>, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 9/20/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 20 Sep 2006, Peter Zijlstra wrote:
>
> > > Which comes naturally with cpusets.
> >
> > How are shared mappings dealt with, are pages charged to the set that
> > first faults them in?
>
> They are charged to the node from which they were allocated. If the
> process is restricted to the node (container) then all pages allocated
> are are charged to the container regardless if they are shared or not.
>

Or you could use the per-vma mempolicy support to bind a large data
file to a particular node, and track shared file usage that way.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
