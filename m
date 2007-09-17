Message-Id: <20070917183507.332345000@sgi.com>
Date: Mon, 17 Sep 2007 11:35:07 -0700
From: travis@sgi.com
Subject: [PATCH 0/1] ppc64: Convert cpu_sibling_map to a per_cpu data array ppc64 v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sfr@canb.auug.org.au, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Stephen Rothwell wrote:
> On Mon, 17 Sep 2007 16:28:31 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> 	the topology (on my POWERPC5+ box) is not correct:
>>
>> cpu0/topology/thread_siblings:0000000f
>> cpu1/topology/thread_siblings:0000000f
>> cpu2/topology/thread_siblings:0000000f
>> cpu3/topology/thread_siblings:0000000f
>>
>> it used to be:
>>
>> cpu0/topology/thread_siblings:00000003
>> cpu1/topology/thread_siblings:00000003
>> cpu2/topology/thread_siblings:0000000c
>> cpu3/topology/thread_siblings:0000000c
> 
> This would be because we are setting up the cpu_sibling map before we
> call setup_per_cpu_areas().

The following patch hopefully should fix this problem.  I'm
not able to build or test it but the few references to 
cpu_sibling_map seem to all occur well after setup_per_cpu_areas
is called.

Thanks Stephen for checking this out!

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
