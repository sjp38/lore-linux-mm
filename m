Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4D06B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:57:43 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so31382574qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:57:43 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id e93si11598510qkh.102.2015.04.24.07.57.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:57:42 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Apr 2015 08:57:42 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9C65119D803E
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:48:44 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3OEthPp34472120
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:55:43 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3OEvd3m009948
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:57:39 -0600
Date: Fri, 24 Apr 2015 07:57:38 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424145738.GZ5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230921020.32297@gentwo.org>
 <55390EE1.8020304@gmail.com>
 <20150423193339.GR5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240909350.7582@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504240909350.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 09:12:07AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
> >
> > DAX
> >
> > 	DAX is a mechanism for providing direct-memory access to
> > 	high-speed non-volatile (AKA "persistent") memory.  Good
> > 	introductions to DAX may be found in the following LWN
> > 	articles:
> 
> DAX is a mechanism to access memory not managed by the kernel and is the
> successor to XIP. It just happens to be needed for persistent memory.
> Fundamentally any driver can provide an MMAPPed interface to allow access
> to a devices memory.

I will take another look, but others in this thread have called out
difficulties with DAX's filesystem nature.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
