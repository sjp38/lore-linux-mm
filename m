Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E44426B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:45:37 -0500 (EST)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id nBIEjY3T007382
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:45:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIEjYCo663696
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:45:34 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id nBIEjYw6011176
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:45:34 GMT
Date: Fri, 18 Dec 2009 15:45:33 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [2.6.33-rc1] slab: possible recursive locking detected
Message-ID: <20091218144533.GA19392@osiris.boeblingen.de.ibm.com>
References: <20091218115843.GB7728@osiris.boeblingen.de.ibm.com>
 <1261141094.5014.11.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261141094.5014.11.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 02:58:13PM +0200, Pekka Enberg wrote:
> Hi Heiko,
> 
> On Fri, 2009-12-18 at 12:58 +0100, Heiko Carstens wrote:
> > Just got this with CONFIG_SLAB:
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.33-rc1-dirty #23
> > ---------------------------------------------
> > events/5/20 is trying to acquire lock:
> >  (&(&parent->list_lock)->rlock){..-...}, at: [<00000000000ee898>] cache_flusharray+0x3c/0x12c
> > 
> > but task is already holding lock:
> >  (&(&parent->list_lock)->rlock){..-...}, at: [<00000000000eee52>] drain_array+0x52/0x100
[...]
>
> Thanks for the report! Does reverting the following commit make the
> warning go away?
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ce79ddc8e2376a9a93c7d42daf89bfcbb9187e62

Yes, with that one reverted the warning is away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
