Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBC96B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:55:06 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so23777339qge.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:55:06 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id j4si11610367qga.33.2015.04.24.07.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:55:05 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Apr 2015 08:55:04 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id ED13F1FF001F
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:46:11 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3OEsg7v40960188
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:54:42 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3OEt0U8031376
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:55:00 -0600
Date: Fri, 24 Apr 2015 07:54:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424145459.GY5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423185240.GO5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 09:30:40AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
> > If by "entire industry" you mean everyone who might want to use hardware
> > acceleration, for example, including mechanical computer-aided design,
> > I am skeptical.
> 
> The industry designs GPUs with super fast special ram and accellerators
> with special ram designed to do fast searches and you think you can demand page
> that stuff in from the main processor?

The demand paging is indeed a drawback for the option of using autonuma
to handle the migration.  And again, this is not intended to replace the
careful hand-tuning that is required to get the last drop of performance
out of the system.  It is instead intended to handle the cases where
the application needs substantially more performance than the CPUs alone
can deliver, but where the cost of full-fledge hand tuning cannot be
justified.

You seem to believe that this latter category is the empty set, which
I must confess does greatly surprise me.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
