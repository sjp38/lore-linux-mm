Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id C8B426B006E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:37:43 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so17315582qcb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:37:43 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id r96si9544026qkr.92.2015.04.23.15.37.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 15:37:42 -0700 (PDT)
Message-ID: <1429828650.4915.51.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 24 Apr 2015 08:37:30 +1000
In-Reply-To: <55390EE1.8020304@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <20150422000538.GB6046@gmail.com>
	 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
	 <20150422131832.GU5561@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
	 <1429756200.4915.19.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504230921020.32297@gentwo.org>
	 <55390EE1.8020304@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 2015-04-23 at 11:25 -0400, Austin S Hemmelgarn wrote:
> Looking at this whole conversation, all I see is two different views on 
> how to present the asymmetric multiprocessing arrangements that have 
> become commonplace in today's systems to userspace.  Your model favors 
> performance, while CAPI favors simplicity for userspace.

I would say it differently.... when you say "CAPI favors..." it's not CAPI,
it's the usage model we are proposing as an option for CAPI and other
similar technology (there's at least one other I can't quite talk about
yet), but basically anything that has the characteristics defined in
the document Paul posted. CAPI is just one such example.

On another hand, CAPI can also perfectly be used as Christoph describes.

The ability to transparently handle and migrate memory is not exclusive
with the ability for an application to explicitly decide where to allocate
its memory and explicitly move the data around. Both options will be provided.

Before the thread degraded into a debate on usage model, this was an
attempt at discussing the technical details of what would be the best
approach to implement the "transparent" model in Linux. I'd like to go back
to it if possible ...

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
