Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 818286B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:52:46 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so76311185ied.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 11:52:46 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id c18si48987igr.39.2015.04.23.11.52.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 11:52:45 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 23 Apr 2015 12:52:45 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8FA3F19D8048
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:43:46 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3NIqNXs40894712
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 11:52:23 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3NIqeKs017145
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:52:41 -0600
Date: Thu, 23 Apr 2015 11:52:40 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150423185240.GO5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, Apr 23, 2015 at 09:38:15AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

[ . . . ]

> > It might not be *your* model based on *your* application but that doesn't mean
> > it's not there, and isn't relevant.
> 
> Sadly this is the way that an entire industry does its thing.

I must confess that I got lost in the pronouns.

If by "this is the way" and "entire industry" you mean hand-tuning
for the former and the specific industry you are in for the latter,
I am with you.  And again, we are not going to do anything that would
prevent hand-tuning.  For example, it will be possible to completely
disable any migration operations that might contribute to OS jitter.
And I have added a requirement that this migration mechanism not
contribute to OS jitter unless it is enabled.  Does that help?

If by "entire industry" you mean everyone who might want to use hardware
acceleration, for example, including mechanical computer-aided design,
I am skeptical.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
