Date: Wed, 16 Nov 2005 11:43:25 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2/2] Fold numa_maps into mempolicy.c
Message-Id: <20051116114325.4f722183.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511161048530.15919@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
	<Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
	<20051115231051.5437e25b.pj@sgi.com>
	<200511160936.04721.ak@suse.de>
	<Pine.LNX.4.62.0511161048530.15919@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> We could make the function local to mempolicy.c if we fold the numa_maps 
> interface into mempolicy.c. That would prevent outside uses of this and so 
> prevent additional outside uses.

Whether or not get_vma_policy is called with a task != current is not
the same question as whether or not some call is made to get_vma_policy
from code not in mm/mempolicy.c

> But then Paul was looking for such a use?

I was just trying to understand the scope of mmap_sem locking in that
code, for some work I am doing in numa_policy_rebind() to rebind vma
mempolicies safely in the current context.  I didn't have a bias as to
what answers I got to my 20^W4 questions, other than that they made
sense to me.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
