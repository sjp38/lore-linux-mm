Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 928D06B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 14:30:56 -0400 (EDT)
Date: Thu, 17 May 2012 13:30:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] slub: refactoring unfreeze_partials()
In-Reply-To: <1337269668-4619-5-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205171329440.12366@router.home>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337269668-4619-5-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2012, Joonsoo Kim wrote:

> I think that these are disadvantages of current implementation,
> so I do refactoring unfreeze_partials().

The reason the current implementation is so complex is to avoid races. The
state of the list and the state of the partial pages must be consistent at
all times.

> Minimizing code in do {} while loop introduce a reduced fail rate
> of cmpxchg_double_slab. Below is output of 'slabinfo -r kmalloc-256'
> when './perf stat -r 33 hackbench 50 process 4000 > /dev/null' is done.

Looks good. If I can convince myself that this does not open up any
new races then I may ack it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
