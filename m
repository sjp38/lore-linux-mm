Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id A5E806B008A
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:19:33 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id b13so38050055qcw.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:19:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si25036qas.7.2015.02.03.15.19.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 15:19:32 -0800 (PST)
Date: Wed, 4 Feb 2015 00:19:22 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC 0/3] Slab allocator array operations
Message-ID: <20150204001922.5650ca4b@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1501231827330.10083@gentwo.org>
References: <20150123213727.142554068@linux.com>
	<20150123145734.aa3c6c6e7432bc3534f2c4cc@linux-foundation.org>
	<alpine.DEB.2.11.1501231827330.10083@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, brouer@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 23 Jan 2015 18:28:00 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Fri, 23 Jan 2015, Andrew Morton wrote:
> 
> > On Fri, 23 Jan 2015 15:37:27 -0600 Christoph Lameter <cl@linux.com> wrote:
> >
> > > Attached a series of 3 patches to implement functionality to allocate
> > > arrays of pointers to slab objects. This can be used by the slab
> > > allocators to offer more optimized allocation and free paths.
> >
> > What's the driver for this?  The networking people, I think?  If so,
> > some discussion about that would be useful: who is involved, why they
> > have this need, who are the people we need to bug to get it tested,
> > whether this implementation is found adequate, etc.

Yes, networking people like me ;-)

I promised Christoph that I will performance benchmark this. I'll start
by writing/performing some micro benchmarks, but it first starts to get
really interesting once we plug it into e.g. the networking stack, as
effects as instruction-cache misses due to code size starts to play a
role.

> 
> Jesper and I gave a talk at LCA about this. LWN has an article on it.

LWN: Improving Linux networking performance
 - http://lwn.net/Articles/629155/
 - YouTube: https://www.youtube.com/watch?v=3XG9-X777Jo

LWN: Toward a more efficient slab allocator
 - http://lwn.net/Articles/629152/
 - YouTube: https://www.youtube.com/watch?v=s0lZzP1jOzI

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
