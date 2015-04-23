Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 445576B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 22:36:44 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so2714710qcb.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 19:36:44 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id f108si521063qga.86.2015.04.22.19.36.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 19:36:43 -0700 (PDT)
Message-ID: <1429756592.4915.23.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Apr 2015 12:36:32 +1000
In-Reply-To: <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <20150422000538.GB6046@gmail.com>
	 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
	 <20150422131832.GU5561@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
	 <20150422170737.GB4062@gmail.com>
	 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 2015-04-22 at 13:17 -0500, Christoph Lameter wrote:
> 
> > But again let me stress that application that want to be in control will
> > stay in control. If you want to make the decission yourself about where
> > things should end up then nothing in all we are proposing will preclude
> > you from doing that. Please just think about others people application,
> > not just yours, they are a lot of others thing in the world and they do
> > not want to be as close to the metal as you want to be. We just want to
> > accomodate the largest number of use case.
> 
> What I think you want to do is to automatize something that should not be
> automatized and cannot be automatized for performance reasons.

You don't know that.

>  Anyone
> wanting performance (and that is the prime reason to use a GPU) would
> switch this off because the latencies are otherwise not controllable and
> those may impact performance severely. There are typically multiple
> parallel strands of executing that must execute with similar performance
> in order to allow a data exchange at defined intervals. That is no longer
> possible if you add variances that come with the "transparency" here.

Stop trying to apply your unique usage model to the entire world :-)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
