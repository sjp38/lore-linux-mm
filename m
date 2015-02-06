Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id DFEC96B0071
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 13:39:31 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id dc16so12197121qab.1
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 10:39:31 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e9si3702322qaa.82.2015.02.06.10.39.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 06 Feb 2015 10:39:31 -0800 (PST)
Date: Fri, 6 Feb 2015 12:39:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/3] Slab allocator array operations
In-Reply-To: <20150204001922.5650ca4b@redhat.com>
Message-ID: <alpine.DEB.2.11.1502061239050.17507@gentwo.org>
References: <20150123213727.142554068@linux.com> <20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org> <alpine.DEB.2.11.1501231827330.10083@gentwo.org> <20150204001922.5650ca4b@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 4 Feb 2015, Jesper Dangaard Brouer wrote:

> I promised Christoph that I will performance benchmark this. I'll start
> by writing/performing some micro benchmarks, but it first starts to get
> really interesting once we plug it into e.g. the networking stack, as
> effects as instruction-cache misses due to code size starts to play a
> role.

Ok I got a patchset here with the options removed. Just the basic ops.
Should I repost that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
