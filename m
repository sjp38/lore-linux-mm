Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id l5SJRhQ2005925
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 20:27:43 +0100
Received: from ug-out-1314.google.com (ugfk3.prod.google.com [10.66.187.3])
	by spaceape8.eur.corp.google.com with ESMTP id l5SJRc6i013025
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 20:27:41 +0100
Received: by ug-out-1314.google.com with SMTP id k3so778952ugf
        for <linux-mm@kvack.org>; Thu, 28 Jun 2007 12:27:41 -0700 (PDT)
Message-ID: <6599ad830706281227o7accdd72t773c6669f1bd97c4@mail.gmail.com>
Date: Thu, 28 Jun 2007 15:27:41 -0400
From: "Paul Menage" <menage@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <20070628115537.56344465.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
	 <20070627151334.9348be8e.pj@sgi.com>
	 <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
	 <20070628003334.1ed6da96.pj@sgi.com>
	 <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
	 <20070628020302.bb0eea6a.pj@sgi.com>
	 <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
	 <20070628115537.56344465.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: David Rientjes <rientjes@google.com>, clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/28/07, Paul Jackson <pj@sgi.com> wrote:
> Would you like to propose a patch, adding a per-cpuset Boolean flag
> that has inheritance properties similar to the memory_spread_* flags?
> Set at the top and inherited on cpuset creation; overridable per-cpuset.
>
> How about calling it "oom_kill_asking_task", defaulting to 0 (the
> default you will like, not the one I will use for my customers.)

Seems that this could be a system global, with just the control file
in the top-level cpuset directory. I can't see people wanting
different behaviour in different cpusets at the same time.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
