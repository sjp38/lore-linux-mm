Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 57B5F6B00E3
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 08:00:39 -0400 (EDT)
Date: Fri, 5 Apr 2013 13:00:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA Autobalancing Kernel 3.8
Message-ID: <20130405120034.GA2623@suse.de>
References: <515A87C3.1000309@profihost.ag>
 <20130402104844.GE32241@suse.de>
 <515AC3EE.1030803@profihost.ag>
 <20130402125408.GG32241@suse.de>
 <515AEC71.9020704@profihost.ag>
 <20130403140344.GA5811@suse.de>
 <515C388C.5040903@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515C388C.5040903@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

On Wed, Apr 03, 2013 at 04:11:24PM +0200, Stefan Priebe - Profihost AG wrote:
> Am 03.04.2013 16:03, schrieb Mel Gorman:
> >> I've now tested 3.9-rc5 this gaves me a slightly different kernel log:
> >> [  197.236518] pigz[2908]: segfault at 0 ip           (null) sp
> >> 00007f347bffed00 error 14
> >> [  197.237632] traps: pigz[2915] general protection ip:7f3482dbce2d
> >> sp:7f3473ffec10 error:0 in libz.so.1.2.3.4[7f3482db7000+17000]
> >> [  197.330615]  in pigz[400000+10000]
> >>
> >> With 3.8 it is the same as with 3.8.4 or 3.8.5.
> >>
> > 
> > Ok. Are there NUMA machines were you do *not* see this problem?
> Sadly no.
> 
> I can really fast reproduce it with this one:
> 1.) Machine with only 16GB Mem
> 2.) compressing two 60GB Files in parallel with pigz consuming all cores
> 

Ok, I'm dealing with this slower than I'd like due to an unfortunate
abundance of bugs right now. I am putting together a reproduction case but
I still can't trigger it unfortunately. Can you post your .config in case
it's my kernel config that is the reason I can't see the problem please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
