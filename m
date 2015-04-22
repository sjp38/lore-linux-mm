Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 380636B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:18:40 -0400 (EDT)
Received: by qgej70 with SMTP id j70so83039756qge.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:18:40 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id m42si4995384qkh.91.2015.04.22.06.18.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 06:18:39 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Apr 2015 07:18:38 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3901D1FF001F
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 07:09:45 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3MDIYmR41681044
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:18:34 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3MDIYwL007094
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 07:18:34 -0600
Date: Wed, 22 Apr 2015 06:18:32 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422131832.GU5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, Apr 21, 2015 at 07:50:02PM -0500, Christoph Lameter wrote:
> On Tue, 21 Apr 2015, Jerome Glisse wrote:

[ . . . ]

> > Paul is working on a platform that is more advance that the one HMM try
> > to address and i believe the x86 platform will not have functionality
> > such a CAPI, at least it is not part of any roadmap i know about for
> > x86.
> 
> We will be one of the first users of Paul's Platform. Please do not do
> crazy stuff but give us a sane solution where we can control the
> hardware. No strange VM hooks that automatically move stuff back and forth
> please. If you do this we will have to disable them anyways because they
> would interfere with our needs to have the code not be disturbed by random
> OS noise. We need detailed control as to when and how we move data.

I completely agree that some critically important use cases, such as
yours, will absolutely require that the application explicitly choose
memory placement and have the memory stay there.

Requirement 2 was supposed to be getting at this by saying "explicitly
or implicitly allocated", with the "explicitly" calling out your use
case.  How should I reword this to better bring this out?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
