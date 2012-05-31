Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 107FE6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 21:03:02 -0400 (EDT)
Received: by dakp5 with SMTP id p5so647880dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 18:03:01 -0700 (PDT)
Date: Wed, 30 May 2012 18:02:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V7 02/14] hugetlbfs: don't use ERR_PTR with VM_FAULT*
 values
In-Reply-To: <1338388739-22919-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1205301801060.25774@chino.kir.corp.google.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 30 May 2012, Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> The current use of VM_FAULT_* codes with ERR_PTR requires us to ensure
> VM_FAULT_* values will not exceed MAX_ERRNO value.  Decouple the
> VM_FAULT_* values from MAX_ERRNO.
> 

Yeah, but is there a reason for using VM_FAULT_HWPOISON_LARGE_MASK since 
that's the only VM_FAULT_* value that is greater than MAX_ERRNO?  The rest 
of your patch set doesn't require this, so I think this change should just 
be dropped.  (And PTR_ERR() still returns long, this wasn't fixed from my 
original review.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
