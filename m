Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id CB7356B005C
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 08:43:34 -0400 (EDT)
Message-ID: <4FF439D0.1000603@parallels.com>
Date: Wed, 4 Jul 2012 16:40:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if
 SLUB is used
References: <1340617984.13778.37.camel@ThinkPad-T420>  <1340618099.13778.39.camel@ThinkPad-T420>  <alpine.DEB.2.00.1207031344240.14703@router.home>  <alpine.DEB.2.00.1207031535330.14703@router.home> <1341392420.18505.41.camel@ThinkPad-T420>
In-Reply-To: <1341392420.18505.41.camel@ThinkPad-T420>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On 07/04/2012 01:00 PM, Li Zhong wrote:
> On Tue, 2012-07-03 at 15:36 -0500, Christoph Lameter wrote:
>> > Looking through the emails it seems that there is an issue with alias
>> > strings. 
> To be more precise, there seems no big issue currently. I just wanted to
> make following usage of kmem_cache_create (SLUB) possible:
> 
> 	name = some string kmalloced
> 	kmem_cache_create(name, ...)
> 	kfree(name);

Out of curiosity: Why?
This is not (currently) possible with the other allocators (may change
with christoph's unification patches), so you would be making your code
slub-dependent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
