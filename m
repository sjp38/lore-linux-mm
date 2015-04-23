Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6FC6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:20:57 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so69360206ied.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:20:57 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id ww5si7137695icb.56.2015.04.23.07.20.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 07:20:56 -0700 (PDT)
Date: Thu, 23 Apr 2015 09:20:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <1429756070.4915.17.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.11.1504230914060.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <1429756070.4915.17.camel@kernel.crashing.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

> > There are hooks in glibc where you can replace the memory
> > management of the apps if you want that.
>
> We don't control the app. Let's say we are doing a plugin for libfoo
> which accelerates "foo" using GPUs.

There are numerous examples of malloc implementation that can be used for
apps without modifying the app.
>
> Now some other app we have no control on uses libfoo. So pointers
> already allocated/mapped, possibly a long time ago, will hit libfoo (or
> the plugin) and we need GPUs to churn on the data.

IF the GPU would need to suspend one of its computation thread to wait on
a mapping to be established on demand or so then it looks like the
performance of the parallel threads on a GPU will be significantly
compromised. You would want to do the transfer explicitly in some fashion
that meshes with the concurrent calculation in the GPU. You do not want
stalls while GPU number crunching is ongoing.

> The point I'm making is you are arguing against a usage model which has
> been repeatedly asked for by large amounts of customer (after all that's
> also why HMM exists).

I am still not clear what is the use case for this would be. Who is asking
for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
