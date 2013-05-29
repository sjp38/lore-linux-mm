Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 72B0D6B00D8
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:26:07 -0400 (EDT)
Date: Wed, 29 May 2013 12:26:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
Message-Id: <20130529122605.082cbb1ad8f5cbc9e82e7b16@linux-foundation.org>
In-Reply-To: <1369265838.27102.351.camel@schen9-DESK>
References: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	<20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
	<1369178849.27102.330.camel@schen9-DESK>
	<20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
	<1369183390.27102.337.camel@schen9-DESK>
	<20130522002020.60c3808f.akpm@linux-foundation.org>
	<1369265838.27102.351.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 22 May 2013 16:37:18 -0700 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Currently the per cpu counter's batch size for memory accounting is
> configured as twice the number of cpus in the system.  However,
> for system with very large memory, it is more appropriate to make it
> proportional to the memory size per cpu in the system.
> 
> For example, for a x86_64 system with 64 cpus and 128 GB of memory,
> the batch size is only 2*64 pages (0.5 MB).  So any memory accounting
> changes of more than 0.5MB will overflow the per cpu counter into
> the global counter.  Instead, for the new scheme, the batch size
> is configured to be 0.4% of the memory/cpu = 8MB (128 GB/64 /256),
> which is more inline with the memory size.

I renamed the patch to "mm: tune vm_committed_as percpu_counter
batching size".

Do we have any performance testing results?  They're pretty important
for a performance-improvement patch ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
