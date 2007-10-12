Date: Fri, 12 Oct 2007 10:27:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] Mem Policy: Fixup Shm and Interleave Policy Reference
 Counting - V2
In-Reply-To: <1192199714.7901.20.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710121025020.8605@schroedinger.engr.sgi.com>
References: <20071010205837.7230.42818.sendpatchset@localhost>
 <20071010205849.7230.81877.sendpatchset@localhost>
 <Pine.LNX.4.64.0710101415470.32488@schroedinger.engr.sgi.com>
 <1192129628.5036.23.camel@localhost>  <Pine.LNX.4.64.0710111824290.1181@schroedinger.engr.sgi.com>
 <1192199714.7901.20.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007, Lee Schermerhorn wrote:

> In the meantime, however, if anyone tries to apply a policy [mbind] to a
> SHM_HUGETLB segment, they will BUG-out on the 2nd page fault with the
> current upstream [2.6.23] code.  Kind of serious I think...

And even after the fix they will have trouble with cpusets constraints 
that do not match the mpol bind set?

> > Nope. Its falling back to the task policy.
> 
> But, the get_policy() vm_op can overwrite 'pol' with a NULL return
> value.  This can happen when you have a real shmem segment with default
> policy == NULL/no policy.   See below:

Ah. The logical fix then is to define an additional temporary variable and
only overwrite the pol variable if a policy has been returned? That would 
be consistent with how the vma policies are handled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
