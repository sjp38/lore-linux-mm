Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA426B0038
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:09:40 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so31633431qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:09:40 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id f12si11616680qkh.128.2015.04.24.08.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 08:09:39 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so31633170qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:09:39 -0700 (PDT)
Date: Fri, 24 Apr 2015 11:09:36 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424150935.GB3840@gmail.com>
References: <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230921020.32297@gentwo.org>
 <55390EE1.8020304@gmail.com>
 <20150423193339.GR5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240909350.7582@gentwo.org>
 <20150424145738.GZ5561@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150424145738.GZ5561@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Austin S Hemmelgarn <ahferroin7@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 07:57:38AM -0700, Paul E. McKenney wrote:
> On Fri, Apr 24, 2015 at 09:12:07AM -0500, Christoph Lameter wrote:
> > On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> > 
> > >
> > > DAX
> > >
> > > 	DAX is a mechanism for providing direct-memory access to
> > > 	high-speed non-volatile (AKA "persistent") memory.  Good
> > > 	introductions to DAX may be found in the following LWN
> > > 	articles:
> > 
> > DAX is a mechanism to access memory not managed by the kernel and is the
> > successor to XIP. It just happens to be needed for persistent memory.
> > Fundamentally any driver can provide an MMAPPed interface to allow access
> > to a devices memory.
> 
> I will take another look, but others in this thread have called out
> difficulties with DAX's filesystem nature.

Do not waste your time on that this is not what we want. Christoph here
is more than stuborn and fails to see the world.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
