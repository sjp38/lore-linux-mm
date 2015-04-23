Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7901E6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:10:16 -0400 (EDT)
Received: by qgej70 with SMTP id j70so8513701qge.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:10:16 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id 68si8208331qhs.39.2015.04.23.07.10.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 07:10:15 -0700 (PDT)
Date: Thu, 23 Apr 2015 09:10:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <1429756592.4915.23.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.11.1504230907330.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com> <alpine.DEB.2.11.1504221306200.26217@gentwo.org> <1429756592.4915.23.camel@kernel.crashing.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

> >  Anyone
> > wanting performance (and that is the prime reason to use a GPU) would
> > switch this off because the latencies are otherwise not controllable and
> > those may impact performance severely. There are typically multiple
> > parallel strands of executing that must execute with similar performance
> > in order to allow a data exchange at defined intervals. That is no longer
> > possible if you add variances that come with the "transparency" here.
>
> Stop trying to apply your unique usage model to the entire world :-)

Much of the HPC apps that the world is using is severely impacted by what
you are proposing. Its the industries usage model not mine. That is why I
was asking about the use case. Does not seem to fit the industry you are
targeting. This is also the basic design principle that got GPUs to work
as fast as they do today. Introducing random memory latencies there will
kill much of the benefit of GPUs there too.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
