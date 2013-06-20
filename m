Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 729F76B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 01:49:50 -0400 (EDT)
Date: Thu, 20 Jun 2013 14:50:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
Message-ID: <20130620055011.GB32061@lge.com>
References: <20130614195500.373711648@linux.com>
 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
 <20130619052203.GA12231@lge.com>
 <0000013f5cd71dac-5c834a4e-c521-4d79-aecc-3e7a6671fb8c-000000@email.amazonses.com>
 <20130620015056.GC13026@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130620015056.GC13026@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, Jun 20, 2013 at 10:50:56AM +0900, Joonsoo Kim wrote:
> Hello, Pekka.
> I attach a right formatted patch with acked by Christoph and
> signed off by me.
> 
> It is based on v3.10-rc6 and top of a patch
> "slub: do not put a slab to cpu partial list when cpu_partial is 0".

One more change is needed in __slab_free(), so I attach v2.

------------------8<-------------------------------------
