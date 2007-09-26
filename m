Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l8Q43Xk2020673
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 05:03:33 +0100
Received: from nz-out-0506.google.com (nzfn1.prod.google.com [10.36.190.1])
	by zps35.corp.google.com with ESMTP id l8Q43WFm009450
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 21:03:32 -0700
Received: by nz-out-0506.google.com with SMTP id n1so1168631nzf
        for <linux-mm@kvack.org>; Tue, 25 Sep 2007 21:03:32 -0700 (PDT)
Message-ID: <6599ad830709252103j40d8abd7s25ba25e8f1df1c88@mail.gmail.com>
Date: Tue, 25 Sep 2007 21:03:31 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <20070925205746.dd74a887.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	 <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	 <20070925181442.aeb7b205.pj@sgi.com>
	 <6599ad830709251822q371c4a62rfdf8911720edb86c@mail.gmail.com>
	 <20070925205746.dd74a887.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/25/07, Paul Jackson <pj@sgi.com> wrote:
> Paul M wrote:
> > You could print any tasks that share memory nodes (in their cpuset)
> > with the OOMing task.
>
> Huh?  I'm mystified.  Why would printing tasks help avoid choosing
> the wrong task to oom kill?

This whole dump is purely for debugging, to help figure out
post-mortem why the OOM occurred. By default the kernel prints all
tasks; this is an attempt to strip out irrelevant tasks.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
