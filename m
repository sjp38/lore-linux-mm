Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7A7716B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 06:48:49 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:48:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA Autobalancing Kernel 3.8
Message-ID: <20130402104844.GE32241@suse.de>
References: <515A87C3.1000309@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515A87C3.1000309@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

On Tue, Apr 02, 2013 at 09:24:51AM +0200, Stefan Priebe - Profihost AG wrote:
> Hello list,
> 
> i was trying to play with the new NUMA autobalancing feature of Kernel 3.8.
> 
> But if i enable:
> CONFIG_ARCH_USES_NUMA_PROT_NONE=y
> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> CONFIG_NUMA_BALANCING=y
> 
> i see random process crashes mostly in libc using vanilla 3.8.4.
> 

Any more details than that? What sort of crashes? Anything in the kernel
log? Any particular pattern to the crashes? Any means of reliably
reproducing it? 3.8 vanilla, 3.8-stable or 3.8 with any other patches
applied?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
