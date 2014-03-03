Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF0B6B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 15:04:40 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e51so3188534eek.21
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 12:04:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si12043812wje.154.2014.03.03.12.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 12:04:38 -0800 (PST)
Date: Mon, 3 Mar 2014 20:04:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Panic on ppc64 with numa_balancing and !sparsemem_vmemmap
Message-ID: <20140303200432.GV6732@suse.de>
References: <20140219180200.GA29257@linux.vnet.ibm.com>
 <20140303172649.GU6732@suse.de>
 <874n3fxfeg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <874n3fxfeg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, riel@redhat.com, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Tue, Mar 04, 2014 at 12:45:19AM +0530, Aneesh Kumar K.V wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > On Wed, Feb 19, 2014 at 11:32:00PM +0530, Srikar Dronamraju wrote:
> >> 
> >> On a powerpc machine with CONFIG_NUMA_BALANCING=y and CONFIG_SPARSEMEM_VMEMMAP
> >> not enabled,  kernel panics.
> >> 
> >
> > This?
> 
> This one fixed that crash on ppc64
> 
> http://mid.gmane.org/1393578122-6500-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
