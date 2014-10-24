Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8C43F6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 10:02:21 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id ar1so2406840iec.10
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 07:02:21 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id s5si288366icf.11.2014.10.24.07.02.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 07:02:20 -0700 (PDT)
Date: Fri, 24 Oct 2014 09:02:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for
 RT)
In-Reply-To: <20141024045630.GD15243@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1410240901020.26767@gentwo.org>
References: <20141022155517.560385718@linux.com> <20141023080942.GA7598@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1410230916090.19494@gentwo.org> <20141024045630.GD15243@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Fri, 24 Oct 2014, Joonsoo Kim wrote:

> In this case, object from cpu1's cpu_cache should be
> different with cpu0's, so allocation would be failed.

That is true for most object pointers unless the value is NULL. Which it
can be. But if this is the only case then the second patch + your approach
would work too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
