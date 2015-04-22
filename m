Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id EF9726B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:25:41 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so85075435qge.3
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 08:25:41 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 143si5349867qhw.9.2015.04.22.08.25.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 08:25:39 -0700 (PDT)
Date: Wed, 22 Apr 2015 10:25:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <1429664686.27410.84.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 22 Apr 2015, Benjamin Herrenschmidt wrote:

> Right, it doesn't look at all like what we want.

Its definitely a way to map memory that is outside of the kernel managed
pool into a user space process. For that matter any device driver could be
doing this as well. The point is that we already have pletora of features
to do this. Putting new requirements on the already
warped-and-screwed-up-beyond-all-hope zombie of a page allocator that we
have today is not the way to do this. In particular what I have head
repeatedly is that we do not want kernel structures alllocated there but
then we still want to use this because we want malloc support in
libraries. The memory has different performance characteristics (for
starters there may be lots of other isssues depending on the device) so we
just add a NUMA "node" with estremely high distance.

There are hooks in glibc where you can replace the memory
management of the apps if you want that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
