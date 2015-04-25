Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id E48EE6B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 07:20:45 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so33026165igb.1
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:20:45 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id b12si7544096icm.26.2015.04.25.04.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 04:20:45 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 25 Apr 2015 05:20:44 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B94D33E4003B
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:20:40 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3PBKJiS34472172
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:20:19 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3PBKeBY018439
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:20:40 -0600
Date: Sat, 25 Apr 2015 04:20:39 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150425112039.GH5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230921020.32297@gentwo.org>
 <55390EE1.8020304@gmail.com>
 <20150423193339.GR5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240909350.7582@gentwo.org>
 <20150424145738.GZ5561@linux.vnet.ibm.com>
 <20150424150935.GB3840@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150424150935.GB3840@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Austin S Hemmelgarn <ahferroin7@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 11:09:36AM -0400, Jerome Glisse wrote:
> On Fri, Apr 24, 2015 at 07:57:38AM -0700, Paul E. McKenney wrote:
> > On Fri, Apr 24, 2015 at 09:12:07AM -0500, Christoph Lameter wrote:
> > > On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> > > 
> > > >
> > > > DAX
> > > >
> > > > 	DAX is a mechanism for providing direct-memory access to
> > > > 	high-speed non-volatile (AKA "persistent") memory.  Good
> > > > 	introductions to DAX may be found in the following LWN
> > > > 	articles:
> > > 
> > > DAX is a mechanism to access memory not managed by the kernel and is the
> > > successor to XIP. It just happens to be needed for persistent memory.
> > > Fundamentally any driver can provide an MMAPPed interface to allow access
> > > to a devices memory.
> > 
> > I will take another look, but others in this thread have called out
> > difficulties with DAX's filesystem nature.
> 
> Do not waste your time on that this is not what we want. Christoph here
> is more than stuborn and fails to see the world.

Well, we do need to make sure that we are correctly representing DAX's
capabilities.  It is a hot topic, and others will probably also suggest
that it be used.  That said, at the moment, I don't see how it would help,
given the need to migrate memory.  Perhaps Boas Harrosh's patch set to
allow struct pages to be associated might help?  But from what I can see,
a fair amount of other functionality would still be required either way.

I am updating the DAX section a bit, but I don't claim that it is complete.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
