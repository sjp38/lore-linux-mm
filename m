Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7362B6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 22:34:31 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so357984vnb.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 19:34:31 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 5si6475519vdu.41.2015.04.22.19.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 19:34:29 -0700 (PDT)
Message-ID: <1429756456.4915.22.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Apr 2015 12:34:16 +1000
In-Reply-To: <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <1429663372.27410.75.camel@kernel.crashing.org>
	 <20150422005757.GP5561@linux.vnet.ibm.com>
	 <1429664686.27410.84.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
	 <20150422163135.GA4062@gmail.com>
	 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 2015-04-22 at 12:14 -0500, Christoph Lameter wrote:
> 
> > Bottom line is we want today anonymous, share or file mapped memory
> > to stay the only kind of memory that exist and we want to choose the
> > backing store of each of those kind for better placement depending
> > on how memory is use (again which can be in the total control of
> > the application). But we do not want to introduce a third kind of
> > disjoint memory to userspace, this is today situation and we want
> > to move forward to tomorrow solution.
> 
> Frankly, I do not see any benefit here, nor a use case and I wonder who
> would adopt this. The future requires higher performance and not more band
> aid.

You may not but we have a large number of customers who do.

In fact I'm quite surprised, what we want to achieve is the most natural
way from an application perspective.

You have something in memory, whether you got it via malloc, mmap'ing a file,
shmem with some other application, ... and you want to work on it with the
co-processor that is residing in your address space. Even better, pass a pointer
to it to some library you don't control which might itself want to use the
coprocessor ....

What you propose can simply not provide that natural usage model with any
efficiency.

It might not be *your* model based on *your* application but that doesn't mean
it's not there, and isn't relevant.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
