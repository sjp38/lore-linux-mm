Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k7LLiunx018378
	for <linux-mm@kvack.org>; Mon, 21 Aug 2006 16:44:57 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k7LLmQDu47699209
	for <linux-mm@kvack.org>; Mon, 21 Aug 2006 14:48:26 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k7LLiunB52777826
	for <linux-mm@kvack.org>; Mon, 21 Aug 2006 14:44:56 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GFHZn-0005GQ-00
	for <linux-mm@kvack.org>; Mon, 21 Aug 2006 14:44:55 -0700
Date: Mon, 21 Aug 2006 14:42:43 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: ZVC: Scale thresholds depending on the size of the system
In-Reply-To: <20060821141619.65e20b59.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608211441160.20201@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608191853150.6123@schroedinger.engr.sgi.com>
 <20060821141619.65e20b59.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0608211444510.20237@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Aug 2006, Andrew Morton wrote:

> One day we'll need to stop adding code which is racy wrt cpu hotplug.
> 
> But now is not the time - once we've 100%-decided how to do that, some
> brave person can start doing cross-kernel sweeps.  I _think_ the way we'll
> do this is in places like this one is preempt_disable(), but that's not
> 100% certain.

It may be best to have rw semaphore that needs to be taken and work that 
into the for_each_cpu/for_each_zone or setup a new macro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
