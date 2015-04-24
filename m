Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 58C496B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:04:14 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so84084578iec.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:04:14 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 5si9790783icu.79.2015.04.24.07.04.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:04:13 -0700 (PDT)
Date: Fri, 24 Apr 2015 09:04:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150423154229.GA2399@gmail.com>
Message-ID: <alpine.DEB.2.11.1504240902230.7582@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com> <alpine.DEB.2.11.1504221306200.26217@gentwo.org> <1429756592.4915.23.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230907330.32297@gentwo.org> <20150423154229.GA2399@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Jerome Glisse wrote:

> The numa code we have today for CPU case exist because it does make
> a difference but you keep trying to restrict GPU user to a workload
> that is specific. Go talk to people doing physic, biology, data
> mining, CAD most of them do not care about latency. They have not
> hard deadline to meet with their computation. They just want things
> to compute as fast as possible and programming to be as easy as it
> can get.

I started working on the latency issues a long time ago because
performance of those labs was restricted by OS processing. A noted problem
was SLABs scanning of its objects every 2 seconds which caused pretty
significant performance regressions due to the delay of the computation in
individual threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
