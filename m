Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 47FC16B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 16:20:40 -0400 (EDT)
Received: by qkdo1 with SMTP id o1so15330437qkd.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 13:20:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l4si41263080qgf.19.2015.10.08.13.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 13:20:39 -0700 (PDT)
Date: Thu, 8 Oct 2015 13:20:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Intel-wired-lan] [Patch V3 5/9] i40e: Use numa_mem_id() to
 better support memoryless node
Message-Id: <20151008132037.fc3887da0818e7d011cb752f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1508191717450.30666@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
	<1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com>
	<4197C471DCF8714FBA1FE32565271C148FFFF4D3@ORSMSX103.amr.corp.intel.com>
	<alpine.DEB.2.10.1508191717450.30666@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Patil, Kiran" <kiran.patil@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, "Nelson, Shannon" <shannon.nelson@intel.com>, "Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C" <donald.c.skidmore@intel.com>, "Vick, Matthew" <matthew.vick@intel.com>, "Ronciak, John" <john.ronciak@intel.com>, "Williams, Mitch A" <mitch.a.williams@intel.com>, "Luck, Tony" <tony.luck@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>

On Wed, 19 Aug 2015 17:18:15 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 19 Aug 2015, Patil, Kiran wrote:
> 
> > Acked-by: Kiran Patil <kiran.patil@intel.com>
> 
> Where's the call to preempt_disable() to prevent kernels with preemption 
> from making numa_node_id() invalid during this iteration?

David asked this question twice, received no answer and now the patch
is in the maintainer tree, destined for mainline.

If I was asked this question I would respond

  The use of numa_mem_id() is racy and best-effort.  If the unlikely
  race occurs, the memory allocation will occur on the wrong node, the
  overall result being very slightly suboptimal performance.  The
  existing use of numa_node_id() suffers from the same issue.

But I'm not the person proposing the patch.  Please don't just ignore
reviewer comments!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
