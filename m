Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f48.google.com (mail-vn0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id DF2156B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 19:46:09 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so5445405vnb.5
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 16:46:09 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id sd6si15048598vdc.17.2015.04.24.16.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 16:46:08 -0700 (PDT)
Message-ID: <1429919153.16571.15.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 25 Apr 2015 09:45:53 +1000
In-Reply-To: <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
References: <1429664686.27410.84.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
	 <20150422163135.GA4062@gmail.com>
	 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
	 <1429756456.4915.22.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
	 <20150423161105.GB2399@gmail.com>
	 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
	 <20150424150829.GA3840@gmail.com>
	 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
	 <20150424164325.GD3840@gmail.com>
	 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 2015-04-24 at 11:58 -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Jerome Glisse wrote:
> 
> > > What exactly is the more advanced version's benefit? What are the features
> > > that the other platforms do not provide?
> >
> > Transparent access to device memory from the CPU, you can map any of the GPU
> > memory inside the CPU and have the whole cache coherency including proper
> > atomic memory operation. CAPI is not some mumbo jumbo marketing name there
> > is real hardware behind it.
> 
> Got the hardware here but I am getting pretty sobered given what I heard
> here. The IBM mumbo jumpo marketing comes down to "not much" now.

Ugh ... first nothing we propose precludes using it with explicit memory
management the way you want. So I don't know why you have a problem
here. We are trying to cover a *different* usage model than yours
obviously. But they aren't exclusive.

Secondly, none of what we are discussing here is supported by *existing*
hardware, so whatever you have is not concerned. There is no CAPI based
coprocessor today that provides cachable memory to the system (though
CAPI as a technology supports it), and no GPU doing that either *yet*.
Today CAPI adapters can own host cache lines but don't expose large
swath of cachable local memory.

Finally, this discussion is not even specifically about CAPI or its
performances. It's about the *general* case of a coherent coprocessor
sharing the MMU. Whether it's using CAPI or whatever other technology
that allows that sort of thing that we may or may not be able to mention
at this point.

CAPI is just an example because architecturally it allows that too.

Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
