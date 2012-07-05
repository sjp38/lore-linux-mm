Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 206896B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 21:42:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 07:11:56 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q651fShA12648832
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 07:11:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q657BGNj028650
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 17:11:16 +1000
Message-ID: <1341452486.18505.49.camel@ThinkPad-T420>
Subject: Re: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if
 SLUB is used
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Thu, 05 Jul 2012 09:41:26 +0800
In-Reply-To: <4FF439D0.1000603@parallels.com>
References: <1340617984.13778.37.camel@ThinkPad-T420>
	 <1340618099.13778.39.camel@ThinkPad-T420>
	 <alpine.DEB.2.00.1207031344240.14703@router.home>
	 <alpine.DEB.2.00.1207031535330.14703@router.home>
	 <1341392420.18505.41.camel@ThinkPad-T420> <4FF439D0.1000603@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On Wed, 2012-07-04 at 16:40 +0400, Glauber Costa wrote:
> On 07/04/2012 01:00 PM, Li Zhong wrote:
> > On Tue, 2012-07-03 at 15:36 -0500, Christoph Lameter wrote:
> >> > Looking through the emails it seems that there is an issue with alias
> >> > strings. 
> > To be more precise, there seems no big issue currently. I just wanted to
> > make following usage of kmem_cache_create (SLUB) possible:
> > 
> > 	name = some string kmalloced
> > 	kmem_cache_create(name, ...)
> > 	kfree(name);
> 
> Out of curiosity: Why?
> This is not (currently) possible with the other allocators (may change
> with christoph's unification patches), so you would be making your code
> slub-dependent.
> 

For slub itself, I think it's not good that: in some cases, the name
string could be kfreed ( if it was kmalloced ) immediately after calling
the cache create; in some other case, the name string needs to be kept
valid until some init calls finished. 

I agree with you that it would make the code slub-dependent, so I'm now
working on the consistency of the other allocators regarding this name
string duplicating thing. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
