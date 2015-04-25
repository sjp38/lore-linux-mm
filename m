Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7F06B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 07:49:40 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so100092189ieb.3
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:49:40 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id j15si1580534ioe.66.2015.04.25.04.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 04:49:39 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 25 Apr 2015 05:49:39 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7E4F419D803E
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:40:41 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3PBnatn53936328
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:49:36 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3PBnaFA004082
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:49:36 -0600
Date: Sat, 25 Apr 2015 04:49:35 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150425114935.GK5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423185240.GO5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
 <20150424145459.GY5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504241048490.9889@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504241048490.9889@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 10:49:28AM -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Paul E. McKenney wrote:
> 
> > can deliver, but where the cost of full-fledge hand tuning cannot be
> > justified.
> >
> > You seem to believe that this latter category is the empty set, which
> > I must confess does greatly surprise me.
> 
> If there are already compromises are being made then why would you want to
> modify the kernel for this? Some user space coding and device drivers
> should be sufficient.

The goal is to gain substantial performance improvement without any
user-space changes.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
