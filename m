Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RN6OMU028147
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 19:06:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RN6O4g333512
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 17:06:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9RN6N0b023273
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 17:06:24 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051027152340.5e3ae2c6.akpm@osdl.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random>
	 <1130425212.23729.55.camel@localhost.localdomain>
	 <20051027151123.GO5091@opteron.random>
	 <20051027112054.10e945ae.akpm@osdl.org>
	 <20051027200434.GT5091@opteron.random>
	 <20051027135058.2f72e706.akpm@osdl.org>
	 <20051027213721.GX5091@opteron.random>
	 <20051027152340.5e3ae2c6.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 27 Oct 2005 16:05:52 -0700
Message-Id: <1130454352.23729.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-27 at 15:23 -0700, Andrew Morton wrote:

> 
> hm.   Tossing ideas out here:
> 
> - Implement the internal infrastructure as you have it
> 
> - View it as a filesystem operation which has MM side-effects.
> 
> - Initially access it via sys_ipc()  (or madvise, I guess.  Both are a bit odd)
> 
> - Later access it via sys_[hole]punch()

Thats exactly what my patch provides. Do you really want to see this
through sys_ipc() or shmctl() ? I personally think madvise() or
sys_holepunch are the closest (since they work on a range).

What else I need to do to make it more palatable ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
