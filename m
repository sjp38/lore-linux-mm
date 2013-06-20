Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id EFDAD6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 01:45:18 -0400 (EDT)
Date: Thu, 20 Jun 2013 14:45:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
Message-ID: <20130620054539.GA32061@lge.com>
References: <20130614195500.373711648@linux.com>
 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
 <20130619052203.GA12231@lge.com>
 <0000013f5cd71dac-5c834a4e-c521-4d79-aecc-3e7a6671fb8c-000000@email.amazonses.com>
 <20130620015056.GC13026@lge.com>
 <51c26ebd.e842320a.5dc1.ffffedfcSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51c26ebd.e842320a.5dc1.ffffedfcSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, Jun 20, 2013 at 10:53:36AM +0800, Wanpeng Li wrote:
> On Thu, Jun 20, 2013 at 10:50:56AM +0900, Joonsoo Kim wrote:
> >On Wed, Jun 19, 2013 at 02:29:29PM +0000, Christoph Lameter wrote:
> >
> >
> >-----------------8<-----------------------------------------------
> >>From a3257adcff89fd89a7ecb26c1247eec511302807 Mon Sep 17 00:00:00 2001
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Date: Wed, 19 Jun 2013 14:05:52 +0900
> >Subject: [PATCH] slub: Make cpu partial slab support configurable
> >
> >cpu partial support can introduce level of indeterminism that is not
> >wanted in certain context (like a realtime kernel). Make it configurable.
> >
> >This patch is based on Christoph Lameter's
> >"slub: Make cpu partial slab support configurable V2".
> >
> 
> As you know, actually cpu_partial is the maximum number of objects kept 
> in the per cpu slab and cpu partial lists of a processor instead of 
> just the maximum number of objects kept in cpu partial lists of a
> processor. The allocation will always fallback to slow path if not 
> config SLUB_CPU_PARTIAL, whether it will lead to more latency?

No, the SLUB maintain a cpu slab even if s->cpu_partial is 0.
It is a violation of definition of cpu_partial as you pointed out, but,
current implementation do this way.

Thanks.

> 
> Regards,
> Wanpeng Li 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
