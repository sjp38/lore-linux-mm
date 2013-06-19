Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 6F9BF6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:29:30 -0400 (EDT)
Date: Wed, 19 Jun 2013 14:29:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
In-Reply-To: <20130619052203.GA12231@lge.com>
Message-ID: <0000013f5cd71dac-5c834a4e-c521-4d79-aecc-3e7a6671fb8c-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com> <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com> <20130619052203.GA12231@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 19 Jun 2013, Joonsoo Kim wrote:

> How about maintaining cpu_partial when !CONFIG_SLUB_CPU_PARTIAL?
> It makes code less churn and doesn't have much overhead.
> At bottom, my implementation with cpu_partial is attached. It uses less '#ifdef'.

Looks good. I am fine with it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
