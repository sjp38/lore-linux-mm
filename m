Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D512D8D0046
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 17:09:06 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p1MM93NZ001386
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:09:03 -0800
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by hpaq14.eem.corp.google.com with ESMTP id p1MM90m0021365
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:09:02 -0800
Received: by pxi17 with SMTP id 17so370333pxi.34
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:09:00 -0800 (PST)
Date: Tue, 22 Feb 2011 14:08:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
In-Reply-To: <4D642F03.5040800@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1102221402150.5929@chino.kir.corp.google.com>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-7-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102221333100.5929@chino.kir.corp.google.com> <4D642F03.5040800@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com

On Tue, 22 Feb 2011, Andi Kleen wrote:

> > This makes the accounting worse, NUMA_LOCAL is defined as "allocation from
> > local node," meaning it's local to the allocating cpu, not local to the
> > node being targeted.
> 
> Local to the process really (and I defined it originally ...)  That is what
> I'm implementing
> 
> I don't think "local to some random kernel daemon which changes mappings on
> behalf of others"
> makes any sense as semantics.
> 

You could make the same argument for anything using kmalloc_node() since 
preferred_zone may very well not be on the allocating cpu's node.  So you 
either define NUMA_LOCAL to account for when a cpu allocates memory local 
to itself (as it's name implies) or you define it to account for when 
memory comes from the preferred_zone's node as determined by the zonelist.  
It's not useful to change it from the former to the latter since it's 
already the definition of NUMA_HIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
