Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id EADB46B0038
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:30:14 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so17237940qcb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:30:14 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id q15si9521491qha.77.2015.04.23.15.30.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 15:30:12 -0700 (PDT)
Message-ID: <1429828197.4915.45.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 24 Apr 2015 08:29:57 +1000
In-Reply-To: <alpine.DEB.2.11.1504230907330.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <20150422000538.GB6046@gmail.com>
	 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
	 <20150422131832.GU5561@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
	 <20150422170737.GB4062@gmail.com>
	 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
	 <1429756592.4915.23.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504230907330.32297@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 2015-04-23 at 09:10 -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:
> 
> > >  Anyone
> > > wanting performance (and that is the prime reason to use a GPU) would
> > > switch this off because the latencies are otherwise not controllable and
> > > those may impact performance severely. There are typically multiple
> > > parallel strands of executing that must execute with similar performance
> > > in order to allow a data exchange at defined intervals. That is no longer
> > > possible if you add variances that come with the "transparency" here.
> >
> > Stop trying to apply your unique usage model to the entire world :-)
> 
> Much of the HPC apps that the world is using is severely impacted by what
> you are proposing. Its the industries usage model not mine. That is why I
> was asking about the use case. Does not seem to fit the industry you are
> targeting. This is also the basic design principle that got GPUs to work
> as fast as they do today. Introducing random memory latencies there will
> kill much of the benefit of GPUs there too.

How would it be impacted ? You can still do dedicated allocations etc...
if you want to do so. I think Jerome gave a pretty good explanation of
the need for the usage model we are proposing, it's also coming from the
industry ...

Ben.


> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
