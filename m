Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l8Q1M8bb013349
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 02:22:09 +0100
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps35.corp.google.com with ESMTP id l8Q1M7Di008909
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 18:22:07 -0700
Received: by py-out-1112.google.com with SMTP id a25so3866845pyi
        for <linux-mm@kvack.org>; Tue, 25 Sep 2007 18:22:07 -0700 (PDT)
Message-ID: <6599ad830709251822q371c4a62rfdf8911720edb86c@mail.gmail.com>
Date: Tue, 25 Sep 2007 18:22:05 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <20070925181442.aeb7b205.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	 <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	 <20070925181442.aeb7b205.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/25/07, Paul Jackson <pj@sgi.com> wrote:
> > It would be nice to be able to do the same thing for cpuset
> > membership, in the event that cpusets are active and the memory
> > controller is not.
>
> But cpusets can overlap.  For those configurations where we use
> CONSTRAINT_CPUSET, I guess this doesn't matter, as we just shoot the
> current task.  But what about configurations using overlapping cpusets
> but not CONSTRAINT_CPUSET?

You could print any tasks that share memory nodes (in their cpuset)
with the OOMing task.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
