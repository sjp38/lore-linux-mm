Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l8PMsle2015789
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 23:54:48 +0100
Received: from nz-out-0506.google.com (nzii28.prod.google.com [10.36.35.28])
	by zps35.corp.google.com with ESMTP id l8PMskG3000912
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 15:54:46 -0700
Received: by nz-out-0506.google.com with SMTP id i28so1227335nzi
        for <linux-mm@kvack.org>; Tue, 25 Sep 2007 15:54:46 -0700 (PDT)
Message-ID: <6599ad830709251554t3c68861ax86c30dece98403e1@mail.gmail.com>
Date: Tue, 25 Sep 2007 15:54:45 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <Pine.LNX.4.64.0709251416410.4831@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	 <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	 <Pine.LNX.4.64.0709251416410.4831@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/25/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Tue, 25 Sep 2007, Paul Menage wrote:
>
> > It would be nice to be able to do the same thing for cpuset
> > membership, in the event that cpusets are active and the memory
> > controller is not.
>
> Maybe come up with some generic scheme that works for all types of memory
> controllers? cpusets is now a type of memory controller right?

Kind of, just the way it's always been. It's just a very different
model to Balbir's memory controller.

Incidentally, I'm considering splitting cpusets into two cgroup
subsystems, cpuset and memset, so that they can be more independent.
Mounting the old "cpuset" filesystem type would still get both of them
as before, so it would be backwards compatible.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
