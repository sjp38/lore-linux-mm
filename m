Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9LG13tP027922
	for <linux-mm@kvack.org>; Fri, 21 Oct 2005 12:01:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9LG13gZ046776
	for <linux-mm@kvack.org>; Fri, 21 Oct 2005 12:01:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9LG12Yv009939
	for <linux-mm@kvack.org>; Fri, 21 Oct 2005 12:01:03 -0400
Date: Fri, 21 Oct 2005 09:00:56 -0700
From: mike kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
Message-ID: <20051021160056.GA32741@w-mikek2.ibm.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020160638.58b4d08d.akpm@osdl.org> <20051020234621.GL5490@w-mikek2.ibm.com> <20051021082849.45dafd27.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051021082849.45dafd27.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 21, 2005 at 08:28:49AM -0700, Paul Jackson wrote:
> Mike wrote:
> > Just to be clear, there are at least two distinct requirements for hotplug.
> > One only wants to remove a quantity of memory (location unimportant). 
> 
> Could you describe this case a little more?  I wasn't aware
> of this hotplug requirement, until I saw you comment just now.

Think of a system running multiple OS's on top of a hypervisor, where
each OS is given some memory for exclusive use.  For multiple reasons
(one being workload management) it is desirable to move resources from
one OS to another.  For example, take memory away from an underutilized
OS and give it to an over utilized OS.

This describes the environment on IBM's mid to upper level POWER systems.
Currently, there is OS support to dynamically move/reassign CPUs and
adapters between different OSs on these systems.

My knowledge of Xen is limited, but this might also apply to that
environment also.  An interesting question comes up if Xen or some
other hypervisor starts vitrtualizing memory.  In such cases, would
it make more sense to allow the hypervisor do all resizing or do
we also need hotplug support in the OS for optimal performance?

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
