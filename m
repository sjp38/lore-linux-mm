Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2385D62001F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 15:13:15 -0400 (EDT)
Date: Wed, 17 Mar 2010 19:11:32 +0000
From: Chris Webb <chris@arachsys.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100317191124.GH1997@arachsys.com>
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315202353.GJ3840@arachsys.com>
 <4B9EC60A.2070101@codemonkey.ws>
 <20100317151409.GY31148@arachsys.com>
 <20100317170501.GB9198@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100317170501.GB9198@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Avi Kivity <avi@redhat.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Vivek Goyal <vgoyal@redhat.com> writes:

> Are you using CFQ in the host? What is the host kernel version? I am not sure
> what is the problem here but you might want to play with IO controller and put
> these guests in individual cgroups and see if you get better throughput even
> with cache=writethrough.

Hi. We're using the deadline IO scheduler on 2.6.32.7. We got better
performance from deadline than from cfq when we last tested, which was
admittedly around the 2.6.30 timescale so is now a rather outdated
measurement.

> If the problem is that if sync writes from different guests get intermixed
> resulting in more seeks, IO controller might help as these writes will now
> go on different group service trees and in CFQ, we try to service requests
> from one service tree at a time for a period before we switch the service
> tree.

Thanks for the suggestion: I'll have a play with this. I currently use
/sys/kernel/uids/N/cpu_share with one UID per guest to divide up the CPU
between guests, but this could just as easily be done with a cgroup per
guest if a side-effect is to provide a hint about IO independence to CFQ.

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
